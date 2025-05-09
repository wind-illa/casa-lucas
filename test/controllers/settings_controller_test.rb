require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get settings_show_url
    assert_response :success
  end

  test "should get delete_account" do
    get settings_delete_account_url
    assert_response :success
  end
end
