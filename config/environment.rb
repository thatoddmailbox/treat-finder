require 'bundler'
Bundler.require

if ENV["RACK_ENV"] == "production"
  $GOOGLE_API_KEY = ENV["GOOGLE_API_KEY"]
  
  $YELP_CONSUMER_KEY = ENV["YELP_CONSUMER_KEY"]
  $YELP_CONSUMER_SECRET = ENV["YELP_CONSUMER_SECRET"]
  $YELP_TOKEN = ENV["YELP_TOKEN"]
  $YELP_TOKEN_SECRET = ENV["YELP_TOKEN_SECRET"]
else
  require_relative "secrets"
end

configure :development do
  set :database, "sqlite3:db/database.db"
end
configure :production do
  ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
end