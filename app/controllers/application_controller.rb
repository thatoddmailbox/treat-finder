
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
  configure do
    enable :sessions
    set :session_secret, 'Put random letters here'
    set :views, "app/views"
    set :public_folder, "public"
  end
  
  get "/" do
    erb :index
  end
  
  post "/find_treats" do
    @results = Yelp.client.search(params[:location], { term: params[:search]   }, { :cc => "US", :lang => "en" })
    
    erb :search_results
  end
  
  
  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def jsObject(obj)
      if obj.class == String
        return jsString(obj)
      elsif obj.class == BurstStruct::Burst
        return jsBStruct(obj)
      else 
        return jsString(obj.to_s)
      end
    end
    
    def jsString(str)
      return "\"" + str.gsub("\"", "\\\"") + "\""
    end
    
    def jsBStruct(hash)
      returnStr = "{"
      first = true
      hash.keys.each do |key|
        if first
          first = false
        else
          returnStr += ", "
        end
        returnStr += key
        returnStr += ": "
        returnStr += jsObject(hash.send(key))
      end
      
      returnStr += "}"
      
      return returnStr
    end

    def jsArray(arr)
      returnStr = "["
      first_time = true
      arr.each do |item|
        if not first_time
          returnStr += ", "
        else
          first_time = false
        end
        returnStr += jsBStruct(item)
      end
      returnStr += "]"
      return returnStr
    end
  end
  
end