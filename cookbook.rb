require 'csv'
require_relative 'recipe'

class Cookbook
  def initialize(csv_file_path)
    @csv_file_path = csv_file_path
    @recipes = []
    load_recipes
  end

  def all
    @recipes
  end

  def add_recipe(recipe)
    @recipes << recipe
    write_csv
  end

  def mark_recipe(index)
    recipe = @recipes[index]
    recipe.mark_as_done
    write_csv
  end

  def remove_recipe(recipe_index)
    @recipes.delete_at(recipe_index)
    write_csv
  end

  private

  def write_csv
    CSV.open(@csv_file_path, 'wb') do |csv|
      @recipes.each do |recipe|
        csv << [recipe.name, recipe.description, recipe.rating, recipe.preptime, recipe.done?]
      end
    end
  end

  def load_recipes
    CSV.foreach(@csv_file_path) do |recipe|
      @recipes << Recipe.new({name: recipe[0], description: recipe[1], rating: recipe[2], preptime: recipe[3], done: recipe[4] })
    end
  end
end
