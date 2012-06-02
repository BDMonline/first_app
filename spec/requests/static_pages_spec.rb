require 'spec_helper'

describe "Static pages" do

let(:base_title) {"Brian's Beautiful Bundle"}

  describe "Home page" do

    it "should have the h1 'Sample App'" do
      visit '/static_pages/home'
      page.should have_selector('h1', :text => 'Sample App')
    end
  end

it "should not have an extended title" do
  visit '/static_pages/home'
  page.should_not have_selector('title',
                    :text => "| Home")
end
  


  describe "Help page" do

    it "should have the h1 'Help'" do
      visit '/static_pages/help'
      page.should have_selector('h1', :text => 'Help')
    end
  end

it "should have the right title" do
  visit '/static_pages/help'
  page.should have_selector('title',
                    :text => "#{base_title} | Help")
end
  
  

  describe "About page" do

    it "should have the h1 'About Brian'" do
      visit '/static_pages/about'
      page.should have_selector('h1', :text => 'About Brian')
    end
  end

it "should have the right title" do
  visit '/static_pages/about'
  page.should have_selector('title',
                    :text => "#{base_title} | About")
end

describe "Contact page" do

    it "should have the h1 'Contact Brian'" do
      visit '/static_pages/contact'
      page.should have_selector('h1', :text => 'Contact Brian')
    end
  end

it "should have the right title" do
  visit '/static_pages/contact'
  page.should have_selector('title',
                    :text => "#{base_title} | Get in touch")
end

end

