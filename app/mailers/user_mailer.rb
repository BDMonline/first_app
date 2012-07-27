class UserMailer < ActionMailer::Base
  default from: "donotreply@stemloops.co.uk"
  def registration_confirmation(user)
  	@user = user
  	mail(:to => user.email, :subject => "Registered", :from => "zero.xwords@ntlworld.com")
  end

  def password_reset(user)
  	@user = user
  	mail(:to => user.email, :subject => "Password Reset")
  end
end
