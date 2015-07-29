require_relative "../../config/environment"

require "open-uri"
require 'yelp'

Yelp.client.configure do |config|
  config.consumer_key = $YELP_CONSUMER_KEY
  config.consumer_secret = $YELP_CONSUMER_SECRET
  config.token = $YELP_TOKEN
  config.token_secret = $YELP_TOKEN_SECRET
end

class ApplicationController < Sinatra::Base
  
  enable :sessions
  set :session_secret, 'this is a cookie secret that you should change to some random letters...'
  
  set :views, "app/views"
  set :public_folder, "public"
  
  get "/" do
    erb :index
  end
  
  post "/find_treats" do
    #result = JSON.parse(open("https://maps.googleapis.com/maps/api/geocode/json?address=" + URI.encode(params[:location])).read)["results"]
    #puts result.inspect
    #puts result[0]["geometry"]["location"].inspect
    
    
    erb :search_results
  end
  
  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
  
end