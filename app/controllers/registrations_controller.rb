class RegistrationsController < ApplicationController
  before_action :set_course
  before_action :set_user
  before_action :authenticate_user

  def add_course
    # TODO: Drop course and redirect to @user
    # Reminder: be sure to check if 
    # 1) @user is a student
    # 2) @user is NOT registered to the @course
    if !@user.is_instructor && !@course.students.include?(@user)
      @course.users << @user
      redirect_to user_path(@user) 
    end   
  end

  def drop_course
    # TODO: Drop course and redirect to @user
    # Reminder: be sure to check if 
    # 1) @user is a student
    # 2) @user is registered to the @course
    if !@user.is_instructor && @course.students.include?(@user)
      @course.users.delete(@user)
      redirect_to user_path(@user)
    end
  end

  private
  
  def set_course
    # TODO: find the course using `course_id`
    @course = Course.find_by(id: params[:course_id])
  end

  def set_user
    # TODO: find the user using `course_id`
    @user = User.find_by(id: params[:user_id])
  end
end