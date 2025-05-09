require "test_helper"

class Main::HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get main_home_index_url
    assert_response :success
  end
end
