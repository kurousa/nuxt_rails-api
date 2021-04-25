class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user
  
  # 現在のユーザーのjsonを返却
  def show
    render json: current_user.my_json
    #render :json => current_user.my_json #ハッシュロケット
  end
end
