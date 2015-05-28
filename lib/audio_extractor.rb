require 'tempfile'

class AudioExtractor
  
  def initialize(vidpath)
    @vidpath = vidpath
  end
  
  def extract
    audpath = "./temp_audio.#{Time.now.ticks}.m4a"
    File.unlink audpath rescue nil
    `ffmpeg -i "#{@vidpath}" -vn -acodec copy "#{audpath}"`
    
    audpath
  end
  
end