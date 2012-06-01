require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the content 'Sample App'" do
      visit '/static_pages/home'
      page.should have_selector('h1', :text => 'Sample App')
    end
  end

it "should have the right title" do
  visit '/static_pages/home'
  page.should have_selector('title',
                    :text => "Big Brian's Bonza Biggie | Home")
end
  


  describe "Help page" do

    it "should have the content 'Help'" do
      visit '/static_pages/help'
      page.should have_selector('h1', :text => 'Help')
    end
  end

it "should have the right title" do
  visit '/static_pages/help'
  page.should have_selector('title',
                    :text => "Big Brian's Bonza Biggie | Help")
end
  
  

  describe "About page" do

    it "should have the content 'About Brian'" do
      visit '/static_pages/about'
      page.should have_selector('h1', :text => 'About Brian')
    end
  end

it "should have the right title" do
  visit '/static_pages/about'
  page.should have_selector('title',
                    :text => "Big Brian's Bonza Biggie | About")
end

end

