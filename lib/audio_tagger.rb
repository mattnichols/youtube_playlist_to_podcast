require 'atomic-parsley-ruby'

class AudioTagger
  
  def initialize(video)
    @video = video
  end
  
  def tag(media_path)
    thumbnail = download_thumbnail
    begin
      puts media_path
      v = AtomicParsleyRuby::Media.new(media_path)
      v.encode do |config|
        config.title @video[:title]
        config.artist @video[:author]
        config.description @video[:description]
        config.podcastFlag true
        config.artwork thumbnail unless thumbnail.nil?
        config.overwrite true
      end
    ensure
      File.unlink(thumbnail) rescue nil
    end
  end
  
  def download_thumbnail
    return nil if @video[:thumbnail].nil?
    
    thumbnail_path = "./temp_artwork.#{Time.now.ticks}.#{File.extname(@video[:thumbnail])}"
    
    `curl --progress-bar --output "#{thumbnail_path}" -g "#{@video[:thumbnail]}"`
    thumbnail_path
  end
  
end