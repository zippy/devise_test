Devisetestapp::Application.routes.draw do
  resources :client_applications

  as :user do
      match '/user/confirmation' => 'confirmations#update', :via => :put, :as=> :update_user_confirmation
  end
  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' },
    :controllers => { :passwords => "passwords",:confirmations => "confirmations" }  do
    get "/login" => "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy"
  end
  
  match '/oauth/authorize' => 'oauth#authorize'
  match '/oauth/access_token' => 'oauth#access_token'
  match '/oauth/user' => 'oauth#user'
  match '/oauth/time' => 'oauth#time'

  root :to => "home#home"
  match '/', :to => "home#home", :as => 'home'

#  match 'login' => 'sessions#new', :as => :new_user_session, :via => get
#  match 'login' => 'sessions#create', :as => :user_session, :via => post
#  match 'logout' => 'sessions#destroy', :as => :destroy_user_session, :via => get
#  match '/user/confirmation' => 'confirmations#update', :as => :update_user_confirmation, :via => put

  match '/private_login' => 'sessions#new_private', :as => :private_login
  match '/users/logged_in' => 'users#logged_in_users', :as => :logged_in_users
  resources :users do
    member do
      put :set_preferences
      put :set_permissions
      get :login_as
      get :password_change
      put :do_password_change
      get :permissions
      get :preferences
    end
  end

  match '/logged_out' => 'home#logged_out', :as => :logged_out
  match '/:controller(/:action(/:id))'
end
