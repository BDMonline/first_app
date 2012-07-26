# == Schema Information
#
# Table name: elements
#
#  id         :integer         not null, primary key
#  category   :string(255)
#  name       :string(255)
#  content    :text
#  tags       :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Element < ActiveRecord::Base
  attr_accessible :content, :name, :tags, :category

  validates :name, presence: true, uniqueness:  { case_sensitive: false }

  validates :category, presence: true, format:{with: /text|video|image/}

  def self.search(search)
    if search
      where('tags LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
  
end
