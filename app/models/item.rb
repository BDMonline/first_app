class Item < ActiveRecord::Base
  attr_accessible :content, :markpolicy, :name, :tags

  validates :name, presence: true, length: { maximum: 50 },
  		uniqueness:  { case_sensitive: false }

end
