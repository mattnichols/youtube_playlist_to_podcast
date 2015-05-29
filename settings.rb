require 'rubygems'
require 'bundler/setup'
require 'dropbox-api'
require 'yaml'

unless File.exists?('./settings.private.yaml') 
  puts "Missing settings.private.yaml. Please create file using template and set credentials."
  exit
end

SETTINGS = YAML.load(File.read('./settings.private.yaml'))

PLAYLISTS = SETTINGS[:playlists]

Dropbox::API::Config.app_key    = SETTINGS[:credentials][:dropbox][:appkey]
Dropbox::API::Config.app_secret = SETTINGS[:credentials][:dropbox][:secret]
Dropbox::API::Config.mode       = "dropbox"

HD_USERNAME = SETTINGS[:credentials][:huffduffer][:login]
HD_PASSWORD = SETTINGS[:credentials][:huffduffer][:password]
