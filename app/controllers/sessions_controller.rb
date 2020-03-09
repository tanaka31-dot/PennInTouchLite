class SessionsController < ApplicationController 
  def new 
  end

  def create 
    # TODO: check if user credential match
    # redirect to the user's show page if successful
    # else render the /login form with message "PennKey or Password Incorrect"
  end
  
  def destroy 
    # TODO: reset session and redirect to /login
  end 
end