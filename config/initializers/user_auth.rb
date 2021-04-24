# JWT初期設定モジュール
module UserAuth
  # JWT有効期限デフォルト値
  # 2週間
  mattr_accessor :token_lifetime
  self.token_lifetime = 2.week

  # 受信者識別
  # 誰のための発行かを明確にするため
  # クライアントのドメインやURLを指定する
  mattr_accessor :token_audience
  self.token_audience = -> {
    ENV['API_DOMAIN']
  }

  # 署名アルゴリズム
  mattr_accessor :token_signature_algorithm
  self.token_signature_algorithm = "HS256"

  # 署名に使用する鍵
  # Railsのシークレットキーで署名および検証を実施
  mattr_accessor :token_secret_signature_key
  self.token_secret_signature_key = -> {
    Rails.application.credentials.secret_key_base
  }

  # 公開鍵
  # 署名アルゴリズムがHS256なので未使用
  mattr_accessor :token_public_key
  self.token_public_key = nil

  # Cookieに保存する際のオブジェクトキー
  mattr_accessor :token_access_key
  self.token_access_key = :access_token

  # ログインユーザーが見つからない場合の例外
  mattr_accessor :not_found_exception_class
  self.not_found_exception_class = ActiveRecord::RecordNotFound
end