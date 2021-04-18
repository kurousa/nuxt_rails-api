Rails.application.routes.draw do
  # 追加
  namespace :api do
    namespace :v1 do
      resources :users, only:[:index]
    end
  end
end
