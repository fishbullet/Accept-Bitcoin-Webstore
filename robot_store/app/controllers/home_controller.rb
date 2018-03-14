class HomeController < ApplicationController
  def index
    @merch = Robot.all.order(:price)
  end
end
