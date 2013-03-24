# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :text
#  tags       :text
#  content    :text            default("[]")
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Course < ActiveRecord::Base
  attr_accessible  :name, :tags
  VALID_CONTENT_REGEX = /\[\]|\[\["\d*"(, "\d*"){2}\](, \["\d*"(, "\d*"){2}\])*\]/
  validates :content, format: { with: VALID_CONTENT_REGEX }
  
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