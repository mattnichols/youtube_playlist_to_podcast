require 'rubygems'
require 'bundler/setup'
require 'dropbox-api'
require 'yaml'
require './lib/web.rb'

unless File.exists?('./settings.private.yaml') 
  puts "Missing settings.private.yaml. Please create file using template and set credentials."
  exit
end

SETTINGS = YAML.load(File.read('./settings.private.yaml'))

PLAYLISTS = SETTINGS[:playlists]

raise "Settings missing :connections:" if SETTINGS[:connections].nil?

Dropbox::API::Config.app_key    = SETTINGS[:connections][:dropbox][:appkey]
Dropbox::API::Config.app_secret = SETTINGS[:connections][:dropbox][:secret]
Dropbox::API::Config.mode       = "dropbox"

PODCAST_TYPE = SETTINGS[:connections].nil? ? SETTINGS[:connections][:feed_type] : "huffduffer"

HD_USERNAME = SETTINGS[:connections][:huffduffer][:login]
HD_PASSWORD = SETTINGS[:connections][:huffduffer][:password]
