# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean         default(FALSE)
#  author          :boolean
#  item_successes  :text            default("[]")
#

# Table name: users

#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null


class User < ActiveRecord::Base
  attr_accessible :email, :name , :password,:password_confirmation  
         #ensures only these columns are acc'ble - don't worry, the p'word ones don't persist.
  has_secure_password
  
  before_save { |user| user.email = email.downcase } #always save email in lowercase
  before_save :create_remember_token
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@winstanley.ac.uk/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
			uniqueness:  { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true

    
  def send_password_reset
    self.update_attribute(:login_token, SecureRandom.urlsafe_base64)
    self.update_attribute(:token_send_time, Time.zone.now)    
    UserMailer.password_reset(self).deliver
  end

  def send_registration_confirmation
    self.update_attribute(:login_token, SecureRandom.urlsafe_base64)
    self.update_attribute(:token_send_time, Time.zone.now)    
    UserMailer.registration_confirmation(self).deliver
  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
