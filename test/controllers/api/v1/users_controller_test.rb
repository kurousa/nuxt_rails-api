require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = active_user
    logged_in(@user)
  end
  
  test "show_action" do
    # レスポンスが正しいか
    get api_url("/users/current_user")
    assert_response 200
    assert_equal(@user.my_json, response_body)
  end
  
end
