require "test_helper"

class Ecommerce::SubcategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ecommerce_subcategories_index_url
    assert_response :success
  end

  test "should get show" do
    get ecommerce_subcategories_show_url
    assert_response :success
  end
end
