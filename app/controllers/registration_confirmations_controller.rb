class RegistrationConfirmationsController < ApplicationController
 
def edit
	  @user = User.find_by_login_token(params[:id])
	  unless @user
	  	redirect_to signin_path, :alert => "Something seems to have gone wrong. Perhaps you had already confirmed your id. Please sign in or sign up again"
	  end


end

def update
	@user = User.find_by_login_token(params[:id])
	if @user
		if @user.confirmed
			sign_in @user
			redirect_to user_path, :confirm => "Registration confirmed.", :id => @user.id
		else
			if @user.token_send_time < 2.hours.ago
				@user.destroy
				redirect_to signup_path, :alert => "Registration code expired. Please sign up again.", :id => @user.id
			else 
				@user.update_attribute(:confirmed, true)
				sign_in @user
				flash[:success]="Congratulations. You've signed up."
				redirect_to user_path(@user),  :id => @user.id
			end
		end
	else
		redirect_to root_path, :alert => "Something seems to have gone wrong. Please sign in or sign up again."
	end
end

end
