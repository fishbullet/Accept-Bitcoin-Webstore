class AccountsController < ApplicationController
  before_action :authenticate_user!

  def create
    if current_user.deposit_address
      flash[:success] = "You already have deposit address"
      redirect_to root_path
    else
      payments = PaymentProcessor.new
      payments.get_new_address
      if payments.success?
        current_user.update(deposit_address: payments.body)
        flash[:success] = "Address successfully requested"
        redirect_to root_path
      else
        flash[:error] = "Cant get address for you"
        redirect_to root_path
      end
    end
  end
end

