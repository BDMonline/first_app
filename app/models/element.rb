class Element < ActiveRecord::Base
  attr_accessible :content, :name, :tags, :category
end
