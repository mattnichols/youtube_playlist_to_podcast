require 'watir-webdriver'
require "uri"

module PodcastFeed
  
  class Huffduffer
    def duffit(url, source, title, author, description, keywords)
      b = Watir::Browser.new
      begin
        b.goto 'http://huffduffer.com/login'
        b.text_field(:name => "login[username]").set HD_USERNAME
        b.text_field(:name => "login[password]").set HD_PASSWORD
        b.button(:type => 'submit', :text => "Log in").click

        b.goto 'http://huffduffer.com/add'
        b.text_field(:id => 'bookmark_url').set url
        b.text_field(:id => 'bookmark_title').set title
        b.textarea(:id => 'bookmark_description').set "YouTube source: #{URI.encode(source)} \n\n" + description
        b.text_field(:id => 'bookmark_tags').set keywords
        b.button(:type => 'submit', :text => "Huffduff it").click
        b.link(:text => "edit").click
        b.text_field(:name => "bookmark[url]").set url
        b.button(:type => 'submit', :text => "Update").click
      ensure
        b.close
      end
    end
  
    def duffed
      d = []
    
      d
    end
  end
  
end