require 'rails_helper'
require 'bcrypt'

RSpec.describe UsersController, :type => :controller do
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

  describe "When session[:user_id] is not set," do
    it "index should redirect" do
      get :index
      expect(response.status).to eq(302)
    end
    it "show should redirect" do
      get :show, params: {id: student1.id}
      expect(response.status).to eq(302)
    end
    it "new should NOT redirect" do
      get :new
      expect(response.status).to eq(200)
    end
    it "create should successfully create a new user" do
      post :create, params: {user: {first_name: "Student",
        last_name: "Three",
        pennkey: "third_student",
        is_instructor: false,
        password_hash: "eeeeeeee"
      }}
      expect(User.all.count).to eq(5)
    end
    it "create should hash new user passwords" do
      post :create, params: {user: {first_name: "Student",
        last_name: "Four",
        pennkey: "fourth_student",
        is_instructor: false,
        password_hash: "ffffffff"
      }}
      user = User.find_by(pennkey: "fourth_student")
      password_hash = user.password_hash
      expect(password_hash).to be_truthy
      expect(BCrypt::Password.new(password_hash) == "ffffffff").to be_truthy
    end
  end

  describe "When session[:user_id] is set," do
    it "index should prepare @users, @instructors, and @students" do
      get :index, session: {'user_id' => student1.id}
      expect(User.all.count).to eq(4)
      expect(@controller.instance_variable_get(:@users)).to include(instructor1)
      expect(@controller.instance_variable_get(:@students)).not_to include(instructor1)
    end

    it "edit own profile should be allowed" do
      get :edit, session: {'user_id' => instructor1.id}, params: {id: instructor1.id}
      expect(response.status).to eq(200)
    end

    it "update own profile should be successful" do
      post :update, session: {'user_id' => instructor1.id}, 
            params: {
              id: instructor1.id,
              user: {
                first_name: "Instructor",
                last_name: "X",
                pennkey: "X_instructor",
                is_instructor: true,
                password_hash: "ffffffff"
              }
            }
      expect(User.find(instructor1.id).last_name).to eq('X')
    end

    it "edit other's profile should NOT be allowed, and should redirect" do
      get :edit, session: {'user_id' => instructor1.id}, params: {id: instructor2.id}
      expect(response.status).to eq(302)
    end

    it "update other's profile should NOT be allowed, and should redirect" do
      post :update, session: {'user_id' => student1.id}, 
            params: {
              id: instructor1.id,
              user: {
                first_name: "instructor",
                last_name: "X",
                pennkey: "X_instructor",
                is_instructor: true,
                password_hash: "ffffffff"
              }
            }
      expect(User.find(instructor1.id).last_name).to eq('One')
    end
  end

end
