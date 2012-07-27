ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 =>  587,
  :domain               => "gmail.com",
  :user_name            => ENV[EMAIL_USER_NAME],
  :password             => ENV[EMAIL_PASSWORD],
  :authentication       => "plain",
  :enable_starttls_auto => true
}