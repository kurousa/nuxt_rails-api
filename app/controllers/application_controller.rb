class ApplicationController < ActionController::API
  # APIモードでのクッキー取り扱いを可能とするため
  include ActionController::Cookies
  # 認証モジュール
  include UserAuth::Authenticator
end
