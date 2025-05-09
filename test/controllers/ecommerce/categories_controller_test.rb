require "test_helper"

class Ecommerce::CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ecommerce_categories_index_url
    assert_response :success
  end

  test "should get show" do
    get ecommerce_categories_show_url
    assert_response :success
  end
end
