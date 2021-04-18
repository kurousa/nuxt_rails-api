Rails.application.routes.draw do
  # 追加
  namespace :api do
    namespace :v1 do
      # api test action
      resources :hello, only:[:index]
    end
  end
end
