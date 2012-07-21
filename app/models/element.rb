class Element < ActiveRecord::Base
  attr_accessible :content, :name, :tags, :category

  def self.search(search)
    if search
      where('tags LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
  
end
