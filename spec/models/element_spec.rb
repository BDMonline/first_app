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

require 'spec_helper'

describe Element do
  pending "add some examples to (or delete) #{__FILE__}"
end
