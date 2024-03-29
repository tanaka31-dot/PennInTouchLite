Rails.application.routes.draw do
  resources :users
  resources :courses
  root to: 'pages#home'
  
  # RESTful Routes (generated by scaffold)

  # TODO: sessions routes (see /controllers/sessions_controller.rb)
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  # TODO: add/drop courses routes (see /controllers/registrations_controller.rb)
  
  post '/add_course/:user_id/:course_id', to: 'registrations#add_course', as: 'add_couse'
  delete '/drop_course/:user_id/:course_id', to: 'registrations#drop_course', as: 'drop_course'

end
