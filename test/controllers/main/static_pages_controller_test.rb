require "test_helper"

class Main::StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get about" do
    get main_static_pages_about_url
    assert_response :success
  end

  test "should get contact" do
    get main_static_pages_contact_url
    assert_response :success
  end
end
