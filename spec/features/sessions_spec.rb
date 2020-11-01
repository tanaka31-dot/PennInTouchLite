require "rails_helper"

RSpec.feature "Sessions Features", type: :feature do
  let!(:user) { User.create(first_name: "User", last_name: "One", pennkey: "user1", password: "test") }

  describe "new" do
    it "displays the correct form" do
      visit "/login"
      expect(page).to have_field("pennkey")
      expect(page).to have_field("password_hash")
    end
  end

  describe "create" do
    before(:each) do
      visit "/login"
    end

    it "redirects back to the login page if no data is entered" do
      click_button "Save"
      expect(current_path).to eq("/login")
    end

    it "redirects back to the login page if user with pennkey does not exist" do
      fill_in "pennkey", with: "testpennkey"
      fill_in "password_hash", with: "password"
      click_button "Save"
      expect(current_path).to eq("/login")
    end

    it "does not log the user in with incorrect password" do
      fill_in "pennkey", with: "user1"
      fill_in "password_hash", with: "password"
      click_button "Save"
      expect(page.get_rack_session[:user_id]).to be_nil
    end

    it "redirects back to the login page if incorrect password is entered" do
      fill_in "pennkey", with: "user1@test.com"
      fill_in "password_hash", with: "password"
      click_button "Save"
      expect(current_path).to eq("/login")
    end

    it "logs the user in with correct password" do
      fill_in "pennkey", with: "user1"
      fill_in "password_hash", with: "test"
      click_button "Save"
      expect(page.get_rack_session_key("user_id")).to eq(user.id)
    end

    it "redirects to the users page if correct password is entered" do
      fill_in "pennkey", with: "user1"
      fill_in "password_hash", with: "test"
      click_button "Save"
      expect(current_path).to eq("/users/#{user.id}")
    end
  end

  describe "destroy" do
    before(:each) do
      page.set_rack_session(user_id: user.id)
      visit "/login"
      click_link "Log Out"
    end

    it "logs the user out" do
      expect(page.get_rack_session[:user_id]).to be_nil
    end

    it "redirects to the root page" do
      expect(current_path).to eq("/login")
    end
  end
end
