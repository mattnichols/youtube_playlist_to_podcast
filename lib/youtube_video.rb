# require 'tempfile'

class YoutubeVideo
  
  attr_accessor :id
  attr_accessor :download_url
  attr_accessor :keywords
  attr_accessor :url
  
  def initialize(id)
    @id = id
    @info = video_info(id)
    @keywords = @info['keywords'].nil? ? nil : @info['keywords'].first
    @url = "https://www.youtube.com/watch?v=#{id}"
    
    fmt_streams = @info["url_encoded_fmt_stream_map"].first.split(",").collect { |fmt| CGI.parse(fmt) }
    priority_formats = ["22","18","34","35"]
    format_mapping = { "22" => ".mp4","18"  => ".mp4", "34" => ".flv", "35" => ".flv" }
    
    @download_url = nil
    priority_formats.each do |format|
      fmt_streams.each do |fmt|
        @download_url = fmt['url'].first if fmt['itag'].first == format
        @download_format = format_mapping[format]
        break
      end
    end
    
    raise "Valid format not found" if @download_url.nil?
  end
  
  def download
    vidpath = nil
    cnt = 0
    begin
      cnt += 1
      vidpath = "./temp_video.#{Time.now.ticks}#{@download_format}"
      `curl --progress-bar --output "#{vidpath}" -g "#{@download_url}"`
      
      raise StandardError, "Unable to download #{@download_url}" if (not File.exists?(vidpath)) and cnt >= 3
    end until File.exists?(vidpath)
    vidpath
  end
  
  private
  
  def video_info(video_id)
    uri = URI.parse("http://www.youtube.com/get_video_info?video_id=#{video_id}")
    response = Net::HTTP.get_response(uri)
    response = CGI.parse(response.body)
    if response['status'] == ['fail']
      raise StandardError, "Unable to get video information. #{response['reason']}"
    else
      return response
    end
  end
  
end