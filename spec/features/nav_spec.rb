require "rails_helper"

RSpec.feature "Nav Features", type: :feature do
  let!(:user1) { User.create(first_name: "User", last_name: "One", pennkey: "user1", is_instructor: true, password_hash: "test1") }

  context "when no user is logged in" do
    before(:each) do
      visit "/"
    end

    it "does not display link to all users or courses" do
      expect(page).not_to have_link("Users", href: "/users")
      expect(page).not_to have_link("Courses", href: "/courses")
    end

    it "displays Log in and Sign up links" do
      expect(page).to have_link("Log in", href: "/login")
      expect(page).to have_link("Sign up", href: "/users/new")
    end

    it "does not Log out link" do
      expect(page).to_not have_link("Log out")
    end
  end

  context "when a user is logged in" do
    before(:each) do
      page.set_rack_session(user_id: user1.id)
      visit "/"
    end

    it "display's the Users, Courses, and Log out links" do
      expect(page).to have_link("Users", href: "/users")
      expect(page).to have_link("Courses", href: "/courses")
      expect(page).to have_link("Log Out", href: "/logout")
    end

    it "does not display Log in and Sign up links" do
      expect(page).to_not have_link("Log In")
      expect(page).to_not have_link("Sign Up")
    end
  end
end

