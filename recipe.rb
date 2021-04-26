class Recipe
  attr_reader :name, :description, :rating, :preptime

  def initialize( attributes={done: false} )
    @name = attributes[:name]
    @description = attributes[:description]
    @rating = attributes[:rating]
    @preptime = attributes[:preptime]
    @done = attributes[:done]
  end

  def done?
    @done
  end

  def mark_as_done
    @done = true
  end
end
