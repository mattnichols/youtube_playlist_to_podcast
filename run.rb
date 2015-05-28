require './settings.rb'
require './lib/dropboxer.rb'
require './lib/youtube_video.rb'
require './lib/youtube_playlist.rb'
require './lib/youtube_playlist_filter.rb'
require './lib/audio_extractor.rb'
require './lib/huff.rb'
require './lib/time.rb'
require './lib/audio_tagger.rb'

cmd = ARGV[0] || "process"

def load_videos
  videos = []
  PLAYLISTS.each do |p|
    filter = YoutubePlaylistFilter.new(p.delete(:filters))
    videos += filter.filter(YoutubePlaylist.new(p).playlist)
  end
  
  videos.sort_by{ |vid| vid[:uploaded] }
end

if cmd == "list"
  load_videos.each do |vid|
    puts "#{vid[:tag]} - #{vid[:id]} - #{vid[:title]}"
  end
  
elsif cmd == "process"
  # TODO: Check processed from huffduffer feed
  processed = []
  processed = File.readlines('.processed').collect { |l| l.strip } if File.exists?('.processed')
  
  pf = open('.processed', 'a')
  begin
    load_videos.each do |i|
      next if processed.include?(i[:id])
      begin begin begin
        yt = YoutubeVideo.new(i[:id])
        i[:keywords] = yt.keywords
        
        puts "Downloading \"#{i[:title]}\" by #{i[:author]}..."
        vidpath = yt.download
        puts "Extracting audio..."
        audpath = AudioExtractor.new(vidpath).extract
        
        puts "Tagging audio file..."
        AudioTagger.new(i).tag(audpath)
        
        if i[:savevideo]
          puts "Uploading video to Dropbox..."
          Dropboxer.new.upload(vidpath, "Public/Podcast/#{i[:title]}.#{File.extname(vidpath)}")
        end
        
        puts "Uploading audio to Dropbox..."
        share = Dropboxer.new.upload(audpath, "Public/Podcast/#{i[:title]}.m4a")
        
        puts "Posting to Huffduffer..."
        Huff.new.duffit(share, yt.url, i[:title], i[:author], i[:description], (i[:tag].nil? ? "" : "#{i[:tag]},") + i[:keywords])
        
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
  ensure
    pf.close
  end
  
else
  puts "Invalid command #{cmd}"
  
end # process cmd
