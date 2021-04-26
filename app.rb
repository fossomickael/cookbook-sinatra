require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry-byebug'
require 'better_errors'
require_relative 'scrape_allrecipes_service'
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

get '/mark/:index' do
  @index = params[:index].to_i
  cookbook.mark_recipe(@index)
  redirect '/'
end

post '/search' do
  @keyword = params[:keyword]
  html_doc = ScrapeAllrecipesService.new(@keyword).call
  array = []
  html_doc.css('a.card__titleLink.manual-link-behavior').each do |n|
    array << [n['href'] ,n['title']] unless array.include? [n['href'], n['title']] 
  end
  @recipes = array[0..4]
  erb :results
end

post '/add' do
  @url = params[:url]
  recipe_hash = fetch_one_recipe(@url)
  recipe = Recipe.new(recipe_hash)
  cookbook.add_recipe(recipe)
  "recipe added!"
end

def fetch_one_recipe(url)
  #html_file = 'details.html'
  #html_doc = Nokogiri::HTML(File.open(html_file), nil, 'utf-8')
  html_file = URI.open(url).read
  html_doc = Nokogiri::HTML(html_file)
  description = html_doc.css(".recipe-summary").first.text.strip
  ratings = html_doc.css(".review-star-text").first.text.strip
  ratings_number = ratings.match(/\d/)[0]
  prep_time = ""
  html_doc.css(".recipe-meta-item-body").each do |element|
    is_prep_time = element.text.match?(/\d+\s*(hrs?|mins?)(\d+\s*(hrs?|mins?))?/)
    prep_time = element.text.strip if is_prep_time
  end
  name = html_doc.css(".main-header.recipe-main-header h1").first.text.strip
  {name: name, description: description, rating: ratings_number, preptime: prep_time, done: false}  
end