class PasswordResetsController < ApplicationController
	def new
	end
	def create
	  user = User.find_by_email(params[:email].downcase)
	  user.send_password_reset if user
	  redirect_to root_url, :notice => "Please check your email inbox. We have sent password reset instructions."
	end

	def edit
	  @user = User.find_by_login_token!(params[:id])
	end

	def update
		@user = User.find_by_login_token!(params[:id])
		if @user.token_send_time < 2.hours.ago
			redirect_to new_password_reset_path, :alert => "Password reset code has expired."
		elsif @user.update_attributes(params[:user])
			redirect_to root_url, :notice => "Password has been reset."
		else
			render :edit
		end
	end
end
