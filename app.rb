require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry-byebug'
require 'better_errors'
require_relative 'cookbook'
configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end
csv_file   = File.join(__dir__, 'recipes.csv')
cookbook   = Cookbook.new(csv_file)

get '/' do
  @recipes = cookbook.all
  erb :index
end

get '/new' do
  erb :new
end

post '/recipes' do
  @name = params[:name]
  @description = params[:descr]
  @rating = params[:rating]
  @preptime = params[:preptime]
  hash = {name: @name, description: @description, rating: @rating, preptime: @preptime, done:false }
  # 2. Create new recipe
  recipe = Recipe.new(hash)
  # 3. Add to repo
  cookbook.add_recipe(recipe)
  @recipes = cookbook.all
  redirect '/'
end

get '/about' do
  erb :about
end

get '/import' do
  erb :import
end

get '/destroy/:index' do
  @index = params[:index].to_i
  cookbook.remove_recipe(@index)
  redirect '/'
end

