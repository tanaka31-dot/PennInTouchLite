require "rails_helper"

RSpec.feature "Users Features", type: :feature do
  let!(:user1) { User.create(first_name: "User", last_name: "One", pennkey: "user1", is_instructor: true, password_hash: "test1") }
  let!(:user2) { User.create(first_name: "User", last_name: "Two", pennkey: "user2", is_instructor: false, password_hash: "test2") }

  describe "#index" do
    context "when no user is logged in" do
      it "redirects to the login page" do
        visit "/users"
        expect(current_path).to eq("/login")
      end
    end

    context "when there is a user logged in" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        visit "/users"
      end

      it "does not redirect" do
        expect(current_path).to eq("/users")
      end

      it "displays the full name of all the users" do
        expect(page).to have_text(user1.first_name)
        expect(page).to have_text(user2.first_name)
      end

      it "has distinction between instructors and students" do
        expect(page).to have_text("Instructors")
        expect(page).to have_text("Students")
      end

      it "displays a link to every user's show page" do
        expect(page).to have_xpath("//a[@href='/users/#{user1.id}']")
        expect(page).to have_xpath("//a[@href='/users/#{user2.id}']")
      end

      it "displays a My Page link to the current user's show page" do
        click_link "My Page"
        expect(current_path).to eq("/users/#{user1.id}")
      end

      it "does not display links for edit" do
        expect(page).to_not have_xpath("//a[@href='/users/#{user1.id}/edit']")
        expect(page).to_not have_xpath("//a[@href='/users/#{user2.id}/edit']")
      end
    end
  end

  describe "#show" do
    let!(:dept1) { Department.create(code: "AFRC", name: "Africana Studies") }
    let!(:course1) { Course.create(department_id: dept1.id, code: 195, title: "iPhone App Development", description: "A cool class") }

    context "when no user is logged in" do
      it "redirects to the login page" do
        visit "/users/#{user1.id}"
        expect(current_path).to eq("/login")
      end
    end

    context "when the current user is an instructor and is on their own show page" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        visit "/users/#{user1.id}"
      end

      it "displays user info" do
        expect(page).to have_text(user1.full_name)
      end

      it "displays user status (instructor/student)" do
        expect(page).to have_text("Status: Instructor")
      end

      it "displays an edit button" do
        expect(page).to have_xpath("//a[@href='/users/#{user1.id}/edit']")
      end
    end

    context "when the current user is a student and is on thier own show page" do
      before :each do
        page.set_rack_session(user_id: user2.id)
        course1.instructor = user1
        course1.users << user2
        visit "/users/#{user2.id}"
      end

      it "displays user info" do
        expect(page).to have_text(user1.full_name)
      end

      it "displays user status (instructor/student)" do
        expect(page).to have_text("Status: Student")
      end

      it "does not displays an edit button" do
        expect(page).to_not have_xpath("//a[@href='/users/#{user1.id}/edit']")
      end

      it "displays drop course" do
        expect(page).to have_text("Drop Course")
        expect(page).to have_xpath("//a[@href='/drop_course/#{user2.id}/#{course1.id}']")
      end
    end 

    context "when the current user is on another user's show page" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        visit "/users/#{user2.id}"
      end

      it "displays user info" do
        expect(page).to have_text(user2.full_name)
      end

      it "displays user status (instructor/student)" do
        expect(page).to have_text("Status: Student")
      end

      it "does not display an edit button" do
        expect(page).not_to have_xpath("//a[@href='/users/#{user2.id}/edit']")
      end
    end

    context "when the user is an instructor" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        course1.instructor = user1
        visit "/users/#{user1.id}"
      end

      it "displays courses teaching" do
        expect(page).to have_text("Courses Teaching")
      end

      it "displays course info" do
        expect(page).to have_text(course1.full_code)
      end

      it "displays user as course instructor" do
        expect(user1.full_name).to eq(course1.instructor.full_name)
      end
    end

    context "when the user is a student" do
      before :each do
        page.set_rack_session(user_id: user2.id)
        course1.instructor = user1
        course1.users << user2
        visit "/users/#{user2.id}"
      end

      it "displays courses taking" do
        expect(page).to have_text("Courses Taking")
      end

      it "displays course info" do
        expect(page).to have_text(course1.full_code)
      end
    end
  end

  describe "#new" do
    context "when no user is logged in" do
      it "does not redirect" do
        visit "/users/new"
        expect(current_path).to eq("/users/new")
      end
    end

    context "when there is a user logged in" do
      it "does not redirect" do
        page.set_rack_session(user_id: user1.id)
        visit "/users/new"
        expect(current_path).to eq("/users/new")
      end
    end

    it "displays a form to create a new user" do
      visit "/users/new"
      expect(page).to have_field("user[first_name]")
      expect(page).to have_field("user[last_name]")
      expect(page).to have_field("user[pennkey]")
      expect(page).to have_unchecked_field("user[is_instructor]")
    end

    context "when the user data is valid" do
      before :each do
        visit "/users/new"
        fill_in("user_first_name", with: "Zena")
        fill_in("user_last_name", with: "Kip")
        fill_in("user_pennkey", with: "zenakip")
        fill_in("user_password_hash", with: "12345678")
      end

      it "redirects to the login page when instructor user is created" do
        check "user_is_instructor"
        click_button "Submit"
        expect(current_path).to eq("/login")
      end

      it "creates a new student user" do
        expect { click_button "Submit" }.to change { User.count }.by(1)
      end

      it "redirects to the login page when student user is created" do
        click_button "Submit"
        expect(current_path).to eq("/login")
      end

      it "creates a new instructor user" do
        check "user_is_instructor"
        expect { click_button "Submit" }.to change { User.count }.by(1)
      end
    end
  end

  describe "#edit" do
    context "when no user is logged in" do
      it "redirects to the login page" do
        visit "/users/#{user1.id}/edit"
        expect(current_path).to eq("/login")
      end
    end

    context "when there is a user logged in" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        visit "/users/#{user1.id}/edit"
      end

      it "does not redirect if its the current user" do
        expect(current_path).to eq("/users/#{user1.id}/edit")
      end

      it "displays a pre-populated form to edit a user" do
        expect(find_field("user[first_name]").value).to eq(user1.first_name)
        expect(find_field("user[last_name]").value).to eq(user1.last_name)
        expect(find_field("user[pennkey]").value).to eq(user1.pennkey)
        expect(page).to have_checked_field("user[is_instructor]")
      end
    end
  end
end
