class Profile < ActiveRecord::Base
  attr_accessible :course, :feedback, :item_successes, :tag, :user
end
