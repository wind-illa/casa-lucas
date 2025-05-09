require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get main" do
    get accounts_main_url
    assert_response :success
  end
end
