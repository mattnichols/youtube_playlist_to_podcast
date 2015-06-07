require './settings.rb'
require './lib/dropboxer.rb'
require './lib/youtube_video.rb'
require './lib/youtube_playlist.rb'
require './lib/youtube_playlist_filter.rb'
require './lib/audio_extractor.rb'
require './lib/time.rb'
require './lib/audio_tagger.rb'

require './lib/huffduffer.rb'
require './lib/web.rb'

cmd = ARGV[0] || "process"

def load_videos
  videos = []
  PLAYLISTS.each do |p|
    begin
      filter = YoutubePlaylistFilter.new(p.delete(:filters))
      videos += filter.filter(YoutubePlaylist.new(p).playlist)
    rescue StandardError => e
      puts "Error loading playlist #{p}"
      puts "#{e.message}"
      puts "#{e.backtrace}"
    end
  end
  
  videos.sort_by{ |vid| vid[:uploaded] }
end

processed = []
processed = File.readlines('.processed').collect { |l| l.strip } if File.exists?('.processed')
pf = open('.processed', 'a')

begin
  if cmd == "list"
    load_videos.each do |vid|
      next if processed.include?(vid[:id])
      puts "#{vid.tag} - #{vid.id} - #{vid.title} by #{vid.author}"
    end
    
  elsif cmd == "process"
    load_videos.each do |i|
      next if processed.include?(i[:id])
      begin begin begin
        puts "Downloading \"#{i[:title]}\" by #{i[:author]}..."
        vidpath = i.download
        puts "Extracting audio..."
        audpath = AudioExtractor.new(vidpath).extract
        
        puts "Tagging audio file..."
        AudioTagger.new(i).tag(audpath)
        
        if i[:savevideo]
          puts "Uploading video to Dropbox..."
          path = "Public/Podcast/#{i[:title]}.#{File.extname(vidpath)}"
          puts "Path: #{path}"
          Dropboxer.new.upload(vidpath, path)
        end
        
        puts "Uploading audio to Dropbox..."
        path = "Public/Podcast/#{i[:title]}.m4a"
        puts "Path: #{path}"
        share = Dropboxer.new.upload(audpath, path)
        
        if PODCAST_TYPE == "huffduffer"
          puts "Posting to Huffduffer..."
          PodcastFeed::Huffduffer.new.duffit(share, i.url, i[:title], i[:author], i[:description], (i[:tag].nil? ? "" : "#{i[:tag]},") + i[:keywords])
        elsif PODCAST_TYPE == "podcast_feed"
          puts "Posting to podcast feed..."
          PodcastFeed::Web.new.post(share, i.url, i[:title], i[:author], i[:description], (i[:tag].nil? ? "" : "#{i[:tag]},") + i[:keywords])
        end
        
        pf << "#{i[:id]}\n"
      ensure
        File.unlink vidpath rescue nil
        File.unlink audpath rescue nil
      end
      rescue SignalException
        exit
      end
      rescue StandardError => e
        puts "An error occurred processing #{i[:id]}"
        puts e.message
        puts e.backtrace.inspect
      end
    end
    
  else
    puts "Invalid command #{cmd}"
    
  end # process cmd
  
ensure
  pf.close
end