FactoryGirl.define do
  factory :user do
    name     "Bill"
    email    "bill@bill.com"
    password "foobar"
    password_confirmation "foobar"
  end
end