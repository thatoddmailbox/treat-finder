require 'bundler'
Bundler.require

require_relative "secrets"

configure :development do
  set :database, "sqlite3:db/database.db"
end