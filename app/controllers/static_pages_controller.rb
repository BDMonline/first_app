
class StaticPagesController < ApplicationController
  def home
  	@test = "can you see this?"
  	@params=params
  end

  def help
  end

  def about
  end
end
