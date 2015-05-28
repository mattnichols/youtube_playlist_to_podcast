require 'dropbox-api'

class Dropboxer
  
  def initialize
    login
  end
  
  def login
    access_token, access_secret = File.read(".access").strip.split('?') if File.exists?(".access")
    @client = Dropbox::API::Client.new(:token  => access_token, :secret => access_secret)
  end
  
  def upload(path, destination)
    fname = path
    @new_file = nil
    if fname && !fname.empty? && File.exists?(fname) && (File.ftype(fname) == 'file') && File.stat(fname).readable?
      total_file_size = ::File.size(fname) * 1.0
      @new_file = @client.chunked_upload(destination, File.open(fname), :chunk_size => (1024 * 1024)) do |os, upload|
        percent_complete = (100.0 * ((os * 1.0) / total_file_size)).round(2)
        print "\r#{percent_complete}%"
      end
      puts
      puts "File uploaded."
    else
      raise StandardError, "couldn't find the file #{ fname }"
    end
    
    share = @new_file.share_url(:short_url => false).url.sub("dl=0", "dl=1")
    share = share + "?dl=1" if not share.include?("?")
    share = share + "&dl=1" if not share.include?("dl=1")
    share.sub("www.dropbox.com", "dl.dropboxusercontent.com")
  end

end
