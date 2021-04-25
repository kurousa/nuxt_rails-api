require 'test_helper'

class AuthenticatorTest < ActionDispatch::IntegrationTest
  def setup
    @user = active_user
    @token = @user.to_token
  end

  test "jwt_decode_data_test" do
    payload = UserAuth::AuthToken.new(token: @token).payload
    sub = payload["sub"]
    exp = payload["exp"]
    aud = payload["aud"]

    # subjectの一致確認
    assert_equal(@user.id, sub)
    
    # expの値存在確認
    assert exp.present?
    
    # token有効期限チェック(1分差までは許容)
    assert_in_delta(2.week.from_now, Time.at(exp) , 1.minute)

    # audienceの値存在確認
    assert aud.present?

    # audienceの値は想定通りのものか
    assert_equal(ENV["API_DOMAIN"], aud)

  end

  test "authenticator_user_method_test" do
    key = UserAuth.token_access_key

    #@userとcurrent_userは一致しているか
    cookies[key] = @token
    get api_url("/users/current_user")
    assert_response 200
    assert_equal(@user, @controller.send(:current_user))

    # 無効なトークンからはアクセス不可であること
    invalid_token = @token + "a"
    cookies[key] = invalid_token
    get api_url("/users/current_user")
    assert_response 401 # Unauthorized
    assert @response.body.blank?

    # トークンがない場合アクセス不可であること
    cookies[key] = nil
    get api_url("/users/current_user")
    assert_response 401 # Unauthorized
    assert @response.body.blank?

    # トークン有効期限内であればアクセス可能であること
    travel_to (UserAuth.token_lifetime.from_now - 1.minute) do
      cookies[key] = @token
      get api_url("/users/current_user")
      assert_response 200
      assert_equal(@user, @controller.send(:current_user))
    end
    # トークン有効期限経過後はアクセス不可であること
    travel_to (UserAuth.token_lifetime.from_now + 1.minute) do
      cookies[key] = @token
      get api_url("/users/current_user")
      assert_response 401
      assert @response.body.blank?
    end

    # headerトークンが優先されるか
    cookies[key] = @token
    other_user = User.where.not(id: @user.id).first # @user以外のユーザーを取得
    other_user_header_token = other_user.to_token # @user以外のトークン

    # @user以外のトークンをAuthorizationヘッダーに記載してリクエスト
    get api_url("/users/current_user"), headers: { Authorization: "Bearer #{other_user_header_token}" }
 
    # Authenticatorのトークンがリクエストヘッダーのトークンであるか
    assert_equal(other_user_header_token, @controller.send(:token))
    # current_userが、other_userになっているか
    assert_equal(other_user, @controller.send(:current_user))
  end
end
