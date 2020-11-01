require 'rails_helper'

RSpec.describe RegistrationsController, :type => :controller do
  let!(:instructor1) {
    User.create(
      first_name: "Instructor",
      last_name: "One",
      pennkey: "first_instructor",
      is_instructor: true,
      password_hash: "aaaaaaaa",
    )
  }

  let!(:instructor2) {
    User.create(
      first_name: "Instructor",
      last_name: "Two",
      pennkey: "second_instructor",
      is_instructor: true,
      password_hash: "bbbbbbbb",
    )
  }

  let!(:student1) {
    User.create(
      first_name: "Student",
      last_name: "One",
      pennkey: "first_student",
      is_instructor: false,
      password_hash: "cccccccc",
    )
  }

  let!(:student2) {
    User.create(
      first_name: "Student",
      last_name: "Two",
      pennkey: "second_student",
      is_instructor: false,
      password_hash: "dddddddd",
    )
  }

  let!(:department) {
    Department.create(code: 'CIS', name: 'Computer and Information Science')
  }

  let!(:course1) {
    Course.create(
      department: department,
      code: 196,
      title: 'Ruby on Rails',
      description: "ruby on rails"
    )
  }

  let!(:course2) {
    Course.create(
      department: department,
      code: 197,
      title: 'JavaScript',
      description: "React and Node JS"
    )
  }

  let!(:ownership) {
    Registration.create(user: instructor1, course: course1)
    Registration.create(user: instructor2, course: course2)
  }

  let!(:registration) {
    Registration.create(user: student2, course: course2)
  }
  
  describe "When session[:user_id] is not set," do
    it "add_course should redirect" do
      post :add_course, params: {user_id: student1.id, course_id: course1.id}
      expect(Course.find(course1.id).users.count).to equal(1)
      expect(response.status).to eq(302)
    end
    it "drop_course should redirect" do
      delete :drop_course, params: {user_id: student1.id, course_id: course1.id}
      expect(Course.find(course1.id).users.count).to equal(1)
      expect(response.status).to eq(302)
    end
  end

  describe "When current_user is a student," do
    it "add_course adds him/her to the course" do
      post :add_course, params: {user_id: student1.id, course_id: course1.id}, session: {user_id: student1.id}
      expect(Course.find(course1.id).users.count).to equal(2)
    end
    it "add_course should not work for another user" do
      post :add_course, params: {user_id: student1.id, course_id: course1.id}, session: {user_id: student2.id}
      expect(Course.find(course1.id).users.count).to equal(1)
    end
    it "drop_course drops him/her from the course" do
      delete :drop_course, params: {user_id: student2.id, course_id: course2.id}, session: {user_id: student2.id}
      expect(Course.find(course2.id).users.count).to equal(1)
    end
    it "drop_course should not work for another user" do
      delete :drop_course, params: {user_id: student2.id, course_id: course2.id}, session: {user_id: student1.id}
      expect(Course.find(course2.id).users.count).to equal(2)
    end
  end

end
