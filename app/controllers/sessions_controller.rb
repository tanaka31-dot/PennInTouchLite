class SessionsController < ApplicationController 
  def new 
  end

  def create
    @user = User.find_by_pennkey(params[:session][:pennkey])
    if @user
      if @user.password == params[:session][:password]
        session[:user_id] = @user.id
        redirect_to @user
      else
        @message = "Incorrect password."
        render 'new'
      end
    else
      @message = "User name not found."
      render 'new'
    end
    # TODO: check if user credential match
    # redirect to the user's show page if successful
    # else render the /login form with message "PennKey or Password Incorrect"
  end
  
  def destroy 
    # TODO: reset session and redirect to /login
    reset_session
    redirect_to '/login'
  end 
end