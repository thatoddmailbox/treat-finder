require_relative "../../config/environment"

class ApplicationController < Sinatra::Base
  
  enable :sessions
  set :session_secret, 'this is a cookie secret that you should change to some random letters...'
  
  set :views, "app/views"
  set :public_folder, "public"
  
  get "/" do
    erb :index
  end
  
  post "/find_treats" do
    "LOADING TREATS"
  end
  
  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
  
end