require 'test_helper'

class FloodControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
