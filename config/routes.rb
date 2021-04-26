Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # users
      resources :users, only:[] do
        get :current_user, action: :show, on: :collection
      end

      # login, logout
      resources :user_token, only: [:create] do
        delete :destroy, on: :collection
      end

      # projects
      resources :projects, only: [:index]
    end
  end
end