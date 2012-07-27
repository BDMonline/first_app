ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 =>  587,
  :domain               => "gmail.com",
  :user_name            => 'stemloops',
  :password             => 'r0b0t3ach',
  :authentication       => "plain",
  :enable_starttls_auto => true
}