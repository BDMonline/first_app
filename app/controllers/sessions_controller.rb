
class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.confirmed
        sign_in user
        redirect_back_or user
      else
        flash[:failure] = 'Registration not yet confirmed. Check your email for instructions.'
        redirect_to signin_path
      end
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
  
end
