ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # ワーカーそれぞれにSeedデータを投入
  parallelize_setup do |worker|
    load "#{Rails.root}/db/seeds.rb"
  end
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  def active_user
    User.find_by(activated: true)
  end
  
  def api_url(path = "/")
    "#{ENV["BASE_URL"]}/api/v1#{path}"
  end

  def response_body
    JSON.parse(@response.body)
  end

  # テスト用Cookieにトークンを保存した状態にする
  def logged_in(user)
    cookies[UserAuth.token_access_key] = user.to_token
  end
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
