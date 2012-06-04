# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name , :password,:password_confirmation  
         #ensures only these columns are acc'ble - don't worry, the p'word ones don't persist.
  has_secure_password
  
  before_save { |user| user.email = email.downcase } #always save email in lowercase
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
			uniqueness:  { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true
end
