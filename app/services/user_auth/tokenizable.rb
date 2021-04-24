module UserAuth

  # トークン発行及び発行主の検索
  module Tokenizable
    # UserクラスからTokenizableモジュールのメソッドを呼び出せるようにする
    def self.included(base)
      base.extend ClassMethods
    end
    
    ## class method
    module ClassMethods
      def from_token(token)
        auth_token = AuthToken.new(token: token)
        from_token_payload(auth_token.payload)
      end
      
      private
        # payload上のsub(ユーザーID)からユーザを検索
        def from_token_payload(payload)
          find(payload["sub"])
        end
    end

    ## instance method
    # トークンを返す
    def to_token
      AuthToken.new(payload: to_token_payload).token
    end
    
    # 有効期限付きトークンを返す
    def to_lifetime_token(lifetime)
      auth = AuthToken.new(lifetime: lifetime, payload: to_token_payload)
      { token: auth.token, lifetime_text: auth.lifetime_text }
    end

    private
      def to_token_payload
        { sub: id }
      end

  end

end