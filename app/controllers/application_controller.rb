require_relative "../../config/environment"
require_relative "../models/user"

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
  
  before do
    if session[:user_id] and session[:user_id] > -1
      @loggedIn = true
      @user = User.find(session[:user_id])
    else
      @loggedIn = false
    end
  end
  
  get "/" do
    erb :index
  end
  
  post "/find_treats" do
    @results = Yelp.client.search(params[:location], { term: params[:search], limit: 19 }, { :cc => "US", :lang => "en" })
    erb :search_results
  end
  
  get "/login" do
    erb :login
  end
  
  post "/login" do
    if params[:username].chomp == "" or params[:password].chomp == ""
      return "Please enter your username and password."
    end
    
    user = User.find_by_username(params[:username])
    
    if user == nil
      return "Invalid username and password combination."
    end    
    if user.password != params[:password]
      return "Invalid username and password combination."
    end
    
    session[:user_id] = user.id
    
    redirect to("/")
  end
  
  get "/signup" do
    erb :signup
  end
  
  post "/signup" do
    if params[:username].chomp == "" or params[:password].chomp == "" or params[:password_confirm].chomp == ""
      return "Please enter your username and password."
    end
    
    if params[:password] != params[:password_confirm]
      return "The passwords do not match."
    end
    
    if User.find_by_username(params[:username])
      
    end
    
    newuser = User.new
    newuser.username = params[:username]
    newuser.password = params[:password]
    newuser.save
    
    session[:user_id] = newuser.id
    
    redirect to("/")
  end
  
  get "/logout" do
    session[:user_id] = -1
    redirect to("/")
  end
  
  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def jsObject(obj)
      if obj.class == String
        return jsString(obj)
      elsif obj.class == Array
        return jsArray(obj)
      elsif obj.class == BurstStruct::Burst
        return jsBStruct(obj)
      else 
        return jsString(obj.to_s)
      end
    end
    
    def jsString(str)
      return "\"" + str.gsub("\"", "\\\"").gsub("\n", "<br />") + "\""
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
        returnStr += jsObject(item)
      end
      returnStr += "]"
      return returnStr
    end
  end
  
end