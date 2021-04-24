require 'jwt'

module UserAuth

  # JWTの発行及び検証クラス
  class AuthToken
    attr_reader :token
    attr_reader :payload
    attr_reader :lifetime

    def initialize(lifetime: nil, payload: {}, token: nil, options: {})
      # トークンが存在する場合デコード
      if token.present?
        @payload, _ = JWT.decode(token.to_s, decode_key, true, decode_options.merge(options))
        @token = token
      else
        @lifetime = lifetime || UserAuth.token_lifetime # 有効期限
        @payload = claims.merge(payload)
        @token = JWT.encode(@payload, secret_key, algorithm, header_fields)
      end
    end

    # subjectよりユーザー検索
    def entity_for_user
      User.find @payload["sub"]
    end

    def lifetime_text
      time, period = @lifetime.inspect.sub(/s\z/, "").split
      time + I18n.t("datetime.periods.#{period}", default: "")      
    end

    private
      # エンコードに用いる鍵
      def secret_key
        UserAuth.token_secret_signature_key.call
      end
      
      # デコードに用いる鍵
      def decode_key
        UserAuth.token_public_key || secret_key
      end
      
      # アルゴリズム
      def algorithm
        UserAuth.token_signature_algorithm
      end

      # オーディエンスの値チェック
      def verify_audience?
        UserAuth.token_audience.present?
      end

      # オーディエンスの値を返却
      def token_audience
        verify_audience? && UserAuth.token_audience.call
      end

      # トークン有効期限を秒数に変換
      def token_lifetime
        @lifetime.from_now.to_i
      end

      # デコード時オプション
      def decode_options
        {
          aud: token_audience,
          verify_aud: verify_audience?,
          algorithm: algorithm
        }
      end

      # デフォルトクレーム
      def claims
        _claims = {}
        _claims[:exp] = token_lifetime
        _claims[:aud] = token_audience if verify_audience?
        _claims
      end

      # エンコード時のヘッダ
      def header_fields
        { typ: 'JWT' }
      end
  end
end