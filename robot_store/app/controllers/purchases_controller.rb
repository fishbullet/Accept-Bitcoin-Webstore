class PurchasesController < ApplicationController
  before_action :authenticate_user!
  def index
    @robots = current_user.robots
  end

  def create
    if current_user.confirmed.zero?
      flash[:error] = "You have not enough funds"
      redirect_to root_path
    else
      robot = Robot.find(params[:robot_id])
      if robot.price.to_f < current_user.balance && (current_user.balance - robot.price.to_f) > 0
        current_user.purchases.create(
          robot_id: robot.id,
          value: (robot.price.to_f * 100_000_000).to_i
        )
        flash[:success] = "Cheers! You have new robot!"
        redirect_to purchases_path
      else
        flash[:error] = "You have not enough funds"
        redirect_to root_path
      end
    end
  end
end
