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
    
    if @type == "user"
      url = "https://gdata.youtube.com/feeds/api/users/#{@id}/uploads/?v=2&alt=json"
    elsif @type == "playlist"
      url = "https://gdata.youtube.com/feeds/api/playlists/#{@id}/?v=2&alt=json&feature=plcp"
    else
      raise StandardError, "Invalid type: #{@type}"
    end
    
    if not @query.nil?
      url << "&q=#{URI::encode(@query)}"
    end
    
    uri = URI.parse(url)
    loop do
      response = JSON.parse(Net::HTTP.get_response(uri).body)
      break if response['feed']['entry'].nil? # Contains no videos
      
      @playlist << response['feed']['entry'].collect do |cur|
        n = {}
        n[:id] = cur['media$group']['yt$videoid']['$t']
        n[:title] = cur['title']['$t']
        n[:author] = cur['author'].first['name']['$t']
        n[:description] = cur['media$group']['media$description'].nil? ? "" : cur['media$group']['media$description']['$t']
        n[:uploaded] = cur['media$group']['yt$uploaded']['$t']
        n[:thumbnail] = cur['media$group']['media$thumbnail'].nil? ? nil : cur['media$group']['media$thumbnail'].select { |t| t['yt$name'] == "default" }.first['url']
        n[:tag] = @tag
        
        n
      end
      next_url = response['feed']['link'].select { |l| l['rel'] == 'next' }
      if(not next_url.empty?)
        uri = URI.parse(next_url.first['href'])
      else
        break
      end
    end
    @playlist.flatten!
  end
  
end