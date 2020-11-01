require 'rails_helper'

RSpec.describe CoursesController, :type => :controller do
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
  }
  
  describe "When session[:user_id] is not set," do
    it "index should redirect" do
      get :index
      expect(response.status).to eq(302)
    end
    it "show should redirect" do
      controller.params[:id] = 1
      get :show, params: {id: 2}
      expect(response.status).to eq(302)
    end
  end

  describe "When session[:user_id] is set," do
    it "index should return all courses if user is a student" do
      get :index, session: {'user_id' => student1.id}
      expect(@controller.instance_variable_get(:@courses)).to include(course1)
      expect(@controller.instance_variable_get(:@courses)).to include(course2)
    end
    it "index should return all courses if user is an instructor" do
      get :index, session: {'user_id' => instructor1.id}
      expect(@controller.instance_variable_get(:@courses)).to include(course1)
      expect(@controller.instance_variable_get(:@courses)).to include(course2)
    end
  end

  describe "When current_user is a student," do
    it "new should redirect" do
      get :new, session: {'user_id' => student1.id}
      expect(response.status).to eq(302)
    end
    it "create should redirect" do
      post :create, session: {'user_id' => student1.id}
      expect(response.status).to eq(302)
      expect(Course.all.count).to eq(2)
    end
    it "edit should redirect" do
      get :edit, session: {'user_id' => student2.id}, params: {'id' => course1.id}
      expect(response.status).to eq(302)
    end
  end

  describe "When current_user is an instructor," do
    it "new should NOT redirect" do
      get :new, session: {'user_id' => instructor1.id}
      expect(response.status).to eq(200)
    end
    it "user can successfully create a course" do
      post :create, session: {user_id: instructor1.id}, params: {course: {department_id: department.id, code: 198, title: 'Rust', description: 'Rust programming'}}
      expect(response.status).to eq(302)
      expect(Course.all.count).to eq(3)
    end
  end

  describe "When current_user is an instructor and owns the course," do
    it "user can edit course" do
      get :edit, session: {'user_id' => instructor1.id}, params: {'id' => course1.id}
      expect(response.status).to eq(200)
    end

    it "user can update course" do
      post :update, session: {user_id: instructor1.id}, params: {id: course1.id, course: {department_id: department.id, code: 198, title: 'Rust', description: 'Rust programming'}}
      expect(Course.all.count).to eq(2)
      expect(Course.find(course1.id).code).to eq(198)
    end
  end

  describe "When current_user is an instructor but DOES NOT own the course," do
    it "user can NOT edit course, and get redirected" do
      get :edit, session: {'user_id' => instructor2.id}, params: {'id' => course1.id}
      expect(response.status).to eq(302)
    end

    it "user can NOT update course, and get redirected" do
      post :update, session: {user_id: instructor2.id}, params: {id: course1.id, course: {department_id: department.id, code: 198, title: 'Rust', description: 'Rust programming'}}
      expect(Course.all.count).to eq(2)
      expect(Course.find(course1.id).code).to eq(196)
    end
  end

end
