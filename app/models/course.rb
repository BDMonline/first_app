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
  attr_accessible :content, :name, :tags
  VALID_CONTENT_REGEX = /\[\]|\[\["\d*"(, "\d*"){2}\](, \["\d*"(, "\d*"){2}\])*\]/
  validates :content, format: { with: VALID_CONTENT_REGEX }

def self.search(search)
    if search
      where('tags LIKE ?', "%#{search}%")
    else
      scoped
    end
end

end