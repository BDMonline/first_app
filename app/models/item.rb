# == Schema Information
#
# Table name: items
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  tags       :text
#  content    :text
#  markpolicy :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Item < ActiveRecord::Base

	
	attr_accessible :content, :markpolicy, :name, :tags

	validates :name, presence: true, length: { maximum: 50 },
			uniqueness:  { case_sensitive: false }

  def self.search(search,onlyme,user)
    
    if search&&onlyme
      where('tags LIKE ? AND author = ?', "%#{search}%", user)
    elsif search
      where('tags LIKE ?', "%#{search}%")
    elsif onlyme
      where('id = ?', user)
    else
      scoped
    end
  end
  

end
