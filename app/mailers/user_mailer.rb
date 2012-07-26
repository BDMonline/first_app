class UserMailer < ActionMailer::Base
  default from: "donotreply@stemloops.co.uk"
  def registration_confirmation(user)
  	@user = user
  	mail(:to => user.email, :subject => "Registered")
	end
end
