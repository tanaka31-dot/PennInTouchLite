require "rails_helper"

RSpec.feature "Courses Features", type: :feature do
  let!(:user1) { User.create(first_name: "User", last_name: "One", pennkey: "user1", is_instructor: true, password_hash: "test1") }
  let!(:user2) { User.create(first_name: "User", last_name: "Two", pennkey: "user2", is_instructor: false, password_hash: "test2") }
  let!(:dept1) { Department.create(code: "CIS", name: "Computer and Information Sci") }
  let!(:dept2) { Department.create(code: "AFRC", name: "Africana Studies") }
  let!(:course1) { Course.create(department_id: dept1.id, code: 195, title: "iPhone App Development", description: "A cool class") }
  let!(:course2) { Course.create(department_id: dept1.id, code: 197, title: "Javascript", description: "A cooler class") }
  let!(:course3) { Course.create(department_id: dept2.id, code: 196, title: "Ruby on Rails", description: "Best class ever!") }

  describe "#index" do
    context "when no user is logged in" do
      it "redirects to the login page" do
        visit "/courses"
        expect(current_path).to eq("/login")
      end
    end

    context "when an instructor user is logged in" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        course1.instructor = user1
        visit "/courses"
      end

      it "displays a new course link" do
        expect(page).to have_link(href: "/courses/new")
      end

      it "displays links to each course's show page" do
        expect(page).to have_xpath("//a[@href='/courses/#{course1.id}' and not(@data-method='delete')]")
        expect(page).to have_xpath("//a[@href='/courses/#{course2.id}' and not(@data-method='delete')]")
        expect(page).to have_xpath("//a[@href='/courses/#{course3.id}' and not(@data-method='delete')]")
      end

      it "displays an edit link for each course the instructor created" do
        expect(page).to have_link(href: "/courses/#{course1.id}/edit")
      end

      it "does not display an edit link for any course the instructor did not create" do
        expect(page).not_to have_link(href: "/courses/#{course2.id}/edit")
        expect(page).not_to have_link(href: "/courses/#{course3.id}/edit")
      end

      it "does not display an add button to the couse" do
        expect(page).not_to have_link(href: "/add_course/#{user1.id}/#{course1.id}")
        expect(page).not_to have_link(href: "/add_course/#{user1.id}/#{course2.id}")
        expect(page).not_to have_link(href: "/add_course/#{user1.id}/#{course3.id}")
      end
    end

    context "when a student user is logged in" do
      before :each do
        page.set_rack_session(user_id: user2.id)
        course1.users << user2
        visit "/courses/"
      end

      it "does not display a new course link" do
        expect(page).not_to have_link(href: "/courses/new")
      end

      it "displays links to each course's show page" do
        expect(page).to have_xpath("//a[@href='/courses/#{course1.id}' and not(@data-method='delete')]")
        expect(page).to have_xpath("//a[@href='/courses/#{course2.id}' and not(@data-method='delete')]")
        expect(page).to have_xpath("//a[@href='/courses/#{course3.id}' and not(@data-method='delete')]")
      end

      it "does not display an edit link for any course" do
        expect(page).not_to have_link(href: "/courses/#{course1.id}/edit")
        expect(page).not_to have_link(href: "/courses/#{course2.id}/edit")
        expect(page).not_to have_link(href: "/courses/#{course3.id}/edit")
      end

      it "displays add course button when student is not added into course" do
        expect(page).to have_link(href: "/add_course/#{user2.id}/#{course2.id}")
        expect(page).to have_link(href: "/add_course/#{user2.id}/#{course3.id}")
      end

      it "does not display add course button when student is already in course" do
        expect(page).not_to have_link(href: "/add_course/#{user2.id}/#{course1.id}")
      end
    end
  end

  describe "#show" do
    context "when no user is logged in" do
      it "redirects to the login page" do
        visit "/courses/"
        expect(current_path).to eq("/login")
      end
    end

    context "when a student user is logged in" do
      before :each do
        page.set_rack_session(user_id: user2.id)
        visit "/courses/#{course1.id}"
      end

      it "displays course info" do
        expect(page).to have_text(course1.description)
      end

      it "displays links to courses index page" do
        expect(page).to have_link(href: "/courses")
      end

      it "does not display an edit link" do
        expect(page).not_to have_link(href: "/courses/#{course1.id}/edit")
      end
    end

    context "when an instructor user is logged in" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        course1.instructor = user1
      end

      it "displays course info" do
        visit "/courses/#{course1.id}"
        expect(page).to have_text(course1.description)
      end

      it "displays links to courses index page" do
        visit "/courses/#{course1.id}"
        expect(page).to have_link(href: "/courses")
      end

      it "does not display an edit link for course the instructor did not create" do
        visit "/courses/#{course2.id}"
        expect(page).not_to have_link(href: "/courses/#{course2.id}/edit")
      end

      it "displays an edit link for course the instructor created" do
        visit "/courses/#{course1.id}"
        expect(page).to have_link(href: "/courses/#{course1.id}/edit")
      end
    end
  end

  describe "#new" do
    context "when a student user is logged in" do
      it "redirects to the courses index page" do
        page.set_rack_session(user_id: user2.id)
        visit "/courses/new"
        expect(current_path).to eq("/courses")
      end
    end

    context "when an instructor user is logged in" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        visit "/courses/new"
      end

      it "displays a form to create a new course" do
        expect(page).to have_xpath("//form[@action='/courses']")
        expect(page).to have_field("course[code]")
        expect(page).to have_field("course[title]")
        expect(page).to have_field("course[description]")
        expect(page).to have_field("course[department_id]")
      end

      context "when the course data is invalid" do
        it "re-renders the form with errors" do
          click_button "Create Course"
          expect(page).to have_text("Title can't be blank")
        end

        it "does not create a note" do
          expect { click_button "Create Course" }.to change { Course.count }.by(0)
        end
      end

      context "when the course data is valid" do
        before :each do
          page.set_rack_session(user_id: user1.id)
          visit "/courses/new"
          fill_in("course_code", with: 19678)
          fill_in("course_title", with: "Ruby on Rails")
          fill_in("course_description", with: "Best class ever!")
          select dept1.name, from: "course[department_id]"
        end

        it "redirects to the new course page" do
          click_button "Create Course"
          expect(page).to have_text("Ruby on Rails")
          expect(page).to have_text(dept1.code)
        end

        it "creates a new course" do
          expect { click_button "Create Course" }.to change { Course.count }.by(1)
        end
      end
    end
  end

  describe "#edit" do
    context "when a student is logged in" do
      it "redirects the courses index page" do
        page.set_rack_session(user_id: user2.id)
        visit "/courses/#{course1.id}/edit"
        expect(current_path).to eq("/courses")
      end
    end

    context "when the course creator is logged in" do
      before :each do
        page.set_rack_session(user_id: user1.id)
        course1.instructor = user1
        visit "/courses/#{course1.id}/edit"
      end

      it "displays a pre-populated form" do
        expect(page).to have_selector("input[value='#{course1.title}']")
      end

      it "re-renders the form with errors when field is empty" do
        fill_in "course[title]", with: ""
        click_button "Update Course"
        expect(page).to have_text("Title can't be blank")
      end

      it "redirects to the course's show page when all fields are valid" do
        fill_in "course[title]", with: "Updated title"
        click_button "Update Course"
        expect(page).to have_text("Updated title")
      end
    end
  end
end
