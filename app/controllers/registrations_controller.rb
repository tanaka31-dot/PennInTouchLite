class RegistrationsController < ApplicationController
  before_action :set_course
  before_action :set_user

  def add_course
    # TODO: Drop course and redirect to @user
    # Reminder: be sure to check if 
    # 1) @user is a student
    # 2) @user is NOT registered to the @course
  end

  def drop_course
    # TODO: Drop course and redirect to @user
    # Reminder: be sure to check if 
    # 1) @user is a student
    # 2) @user is registered to the @course
  end

  private
  
  def set_course
    # TODO: find the course using `course_id`
  end

  def set_user
    # TODO: find the user using `course_id`
  end
end