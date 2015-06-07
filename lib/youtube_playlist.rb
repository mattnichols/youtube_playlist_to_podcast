require "net/http"
require "uri"
require 'json'

class YoutubePlaylist
  attr_accessor :playlist
  
  def initialize(options = {})
    @id = options[:id]
    @type = options[:type]
    @query = options[:query]
    @tag = options[:tag]
    @playlist = load_playlist
  end
  
  def load_playlist
    @playlist = []
    nextPageToken = ""
    
    loop do
      if @type == "user"
        url = "https://gdata.youtube.com/feeds/api/users/#{@id}/uploads/?v=2&alt=json"
      elsif @type == "playlist"
        url = "https://content.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&playlistId=#{@id}&key=#{YOUTUBE_API_KEY}" + (nextPageToken.empty? ? "" : "&pageToken=#{nextPageToken}")
      else
        raise StandardError, "Invalid type: #{@type}"
      end
      
      if not @query.nil?
        url << "&q=#{URI::encode(@query)}"
      end

      uri = URI.parse(url)

      response = JSON.parse(Net::HTTP.get_response(uri).body)
      # puts response
      
      break if response['items'].nil? # Contains no videos
      
      @playlist << response['items'].collect do |cur|
        n = YoutubeVideo.new(cur['snippet']['resourceId']['videoId'])
        n[:title] = cur['snippet']['title']
        n[:description] = cur['snippet']['description'].nil? ? "" : cur['snippet']['description']
        n[:uploaded] = cur['snippet']['publishedAt']
        n[:thumbnail] = cur['snippet']['thumbnails']['default'].nil? ? nil : cur['snippet']['thumbnails']['default']['url']
        n[:tag] = @tag
        
        n
      end
      nextPageToken = response['nextPageToken']
      if(nextPageToken.nil?)
        break
      end
    end
    @playlist.flatten!
  end
  
end