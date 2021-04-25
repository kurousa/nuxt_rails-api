class Api::V1::UserTokenController < ApplicationController
  
  rescue_from UserAuth.not_found_exception_class, with: :not_found

  before_action :delete_cookie
  before_action :authenticate, only: [:create]

  # login
  def create
    cookies[token_access_key] = cookie_token
    render json: {
      exp: auth.payload[:exp],
      user: entity.my_json
    }
  end

  # logout
  def destroy
    head(:ok)
  end

  private
    # メールアドレスからアクティブなユーザーを探す
    def entity
      @_entity ||= User.find_activated(auth_params[:email])
    end

    def auth_params
      params.require(:auth).permit(:email, :password)
    end

    # トークン発行
    def auth
      @_auth ||= UserAuth::AuthToken.new(payload: { sub: entity.id })
    end

    # クッキー保存に関する設定
    def cookie_token
      {
        value: auth.token,
        expires: Time.at(auth.payload[:exp]), # Cookie有効期限、トークンのexpと一致させる
        secure: Rails.env.production?, # 本番環境では、https通信でのみアクセス可能にする
        http_only: true # Javascriptからのアクセスができないようにする
      }
    end

    # entityが存在しない、entityのパスワードが一致しない場合に404エラーを返す
    def authenticate
      unless entity.present? && entity.authenticate(auth_params[:password])
        raise UserAuth.not_found_exception_class
      end
    end 

    # UserAuth.not_found_exception_class発生時に、ヘッダーレスポンスのみ返す
    def not_found
      head(:not_found)
    end

end
