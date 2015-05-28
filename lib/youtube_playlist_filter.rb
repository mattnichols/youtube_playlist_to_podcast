class YoutubePlaylistFilter
  
  def initialize(filter_defs)
    @filters = filter_defs
  end
  
  def filter(playlist)
    filtered_playlist = []
    playlist.each do |vid|
      include_current = false
      if not @filters[:includes].empty?
        @filters[:includes].each do |incl|
          if vid[:title].downcase.include?(incl.downcase)
            include_current = true
          end
        end
      else
        include_current = true
      end
      
      if not @filters[:excludes].empty?
        temp = []
        @filters[:excludes].each do |excl|
          if vid[:title].downcase.include?(excl.downcase)
            include_current = false
          end
        end
      end
      
      filtered_playlist << vid if include_current
    end
    filtered_playlist
  end
  
end