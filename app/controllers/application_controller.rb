class ApplicationController < ActionController::Base
  helper_method :logged_in?, :current_user
  
  # TODO: implement 3 helper method:
  # 1) check if user is logged in
  # 2) get the current logged-in user
  # 3) redirect to '/login' if not authenticated
end
