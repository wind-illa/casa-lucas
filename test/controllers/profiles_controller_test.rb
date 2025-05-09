require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get profiles_show_url
    assert_response :success
  end

  test "should get information" do
    get profiles_information_url
    assert_response :success
  end

  test "should get addresses" do
    get profiles_addresses_url
    assert_response :success
  end

  test "should get edit_name" do
    get profiles_edit_name_url
    assert_response :success
  end

  test "should get edit_email" do
    get profiles_edit_email_url
    assert_response :success
  end

  test "should get edit_phone" do
    get profiles_edit_phone_url
    assert_response :success
  end

  test "should get edit_dni" do
    get profiles_edit_dni_url
    assert_response :success
  end
end
