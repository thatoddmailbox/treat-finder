require_relative "../../config/environment"
require_relative "../models/user"
require_relative "../models/star"

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
  
  post "/find" do
    @results = Yelp.client.search(params[:location], { term: params[:search], limit: 19 }, { :cc => "US", :lang => "en" })
    erb :search_results
  end
  
  get "/login" do
    if not @loggedIn
    erb :login
    else
      redirect to("/")
    end
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
    if not @loggedIn
      erb :signup
    else
      redirect to("/")
    end
  end
  
  post "/signup" do
    if params[:username].chomp == "" or params[:password].chomp == "" or params[:password_confirm].chomp == ""
      return "Please enter your username and password."
    end
    
    if params[:password] != params[:password_confirm]
      return "The passwords do not match."
    end
    
    if User.find_by_username(params[:username])
      return "That username is already taken!"
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
  
  get "/qleys" do
    erb :qleys
  end
  
  post "/qleyplace" do
    if not @user
      return "Not logged in."
    end
    
    star = Star.find_by(user_id: @user.id, place_id: params[:id])
    
    if star == nil
      star = Star.new
      star.user = @user
      star.place_id = params[:id]
      star.save
      return "on " + Star.where(place_id: params[:id]).length.to_s
    else
      star.destroy
      return "off" + Star.where(place_id: params[:id]).length.to_s
    end
    
    return "Error"
  end
  
  get "/business/:id" do
    erb :details
  end
  
  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def qleyCount(place_id)
      count = Star.where(place_id: place_id).length
      displayStr = count.to_s + " people have Qley'd this place."
      if count == 0
        displayStr = "No one has Qley'd this place."
      elsif count == 1
        displayStr = "1 person has Qley'd this place."
      end
      displayStr
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