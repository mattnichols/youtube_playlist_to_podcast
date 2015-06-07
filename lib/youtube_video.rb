class YoutubeVideo
  @@dynamic_properties = [:keywords, :author, :url, :download_url, :download_format]
  
  def [](key)
    key = key.to_sym
    if(@info.nil? and @@dynamic_properties.include?(key))
      @info = video_info(id)
      
      @props[:keywords] = @info['keywords'].nil? ? nil : @info['keywords'].first
      @props[:author] = @info['author'].nil? ? nil : @info['author'].first
      @props[:url] = "https://www.youtube.com/watch?v=#{id}"
      
      fmt_streams = @info["url_encoded_fmt_stream_map"].first.split(",").collect { |fmt| CGI.parse(fmt) }
      priority_formats = ["22","18","34","35"]
      format_mapping = { "22" => ".mp4","18"  => ".mp4", "34" => ".flv", "35" => ".flv" }
      
      priority_formats.each do |format|
        fmt_streams.each do |fmt|
          @props[:download_url] = @props[:download_url] = fmt['url'].first if fmt['itag'].first == format
          @props[:download_format] = format_mapping[format]
          break
        end
      end
      
      raise "Valid format not found" if @props[:download_url].nil?
    end
    
    @props[key]
  end
  
  def []=(key, value)
    @props[key.to_sym] = value
  end
  
  def initialize(id)
    @props = {}
    
    @props[:id] = @id = id
    @info = nil
  end
  
  def download
    vidpath = nil
    cnt = 0
    begin
      cnt += 1
      vidpath = "./temp_video.#{Time.now.ticks}#{@props[:download_format]}"
      `curl --progress-bar --output "#{vidpath}" -g "#{@props[:download_url]}"`
      
      raise StandardError, "Unable to download #{@props[:download_url]}" if (not File.exists?(vidpath)) and cnt >= 3
    end until File.exists?(vidpath)
    vidpath
  end
  
  private
  
  def method_missing(method_sym, *arguments, &block)
    method_sym = method_sym.to_sym
    return self[method_sym] if (@@dynamic_properties.include?(method_sym))
    return self[method_sym] if @props.has_key?(method_sym)
    super
  end
  
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