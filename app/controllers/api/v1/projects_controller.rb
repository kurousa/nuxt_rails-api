class Api::V1::ProjectsController < ApplicationController
  # 以下、追加
  before_action :authenticate_user

  def index
    # 本来はDBから取得する => current_user.projects
    projects = [
      { id: 1, name: 'Rails MyProject01', updatedAt: '2020-04-01T12:00:00+09:00' },
      { id: 2, name: 'Rails MyProject02', updatedAt: '2020-04-05T12:00:00+09:00' },
      { id: 3, name: 'Rails MyProject03', updatedAt: '2020-04-03T12:00:00+09:00' },
      { id: 4, name: 'Rails MyProject04', updatedAt: '2020-04-04T12:00:00+09:00' },
      { id: 5, name: 'Rails MyProject05', updatedAt: '2020-04-01T12:00:00+09:00' }
    ]
    render json: projects
  end
end
