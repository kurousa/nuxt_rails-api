module UserAuth

  # ユーザー認証モジュール
  module Authenticator

    # トークンからcurrent_userを検索し、存在する場合はオブジェクトを返す。存在しない場合は、401を返す。
    def authenticate_user
      current_user.presence || unauthorized_user
    end

    # クッキーを削除する
    def delete_cookie
      return if cookies[token_access_key].blank?
      cookies.delete(token_access_key)
    end

    private
      # リクエストヘッダーからのトークン取得
      def token_from_request_headers
        request.headers["Authorization"]&.split&.last
      end

      # クッキーのオブジェクトキー
      def token_access_key
        UserAuth.token_access_key
      end

      def token
        # リクエストヘッダーからの取得が優先
        token_from_request_headers || cookies[token_access_key]
      end

      # トークンを基にユーザー検索
      def fetch_entity_from_token
        AuthToken.new(token: token).entity_for_user
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::EncodeError
        nil
      end

      # トークンに紐づくユーザーを返す
      def current_user
        return if token.blank?
        @_current_user ||= fetch_entity_from_token
      end

      # 認証エラー 401エラーを返し、クッキーを削除する
      def unauthorized_user
        head(:unauthorized) && delete_cookie
      end

  end

end
  
