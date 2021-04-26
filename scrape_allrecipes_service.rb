require 'open-uri'
require 'nokogiri'
require_relative 'scrape_allrecipes_service'
class ScrapeAllrecipesService
    def initialize(keyword)
      @keyword = keyword
    end
  
    def call
      # TODO: return a list of `Recipes` built from scraping the web.
      url = "https://www.allrecipes.com/search/results/?search=#{@keyword}"
      html_file = URI.open(url).read
      Nokogiri::HTML(html_file)
    end
  end