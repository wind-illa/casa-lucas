require "test_helper"

class Ecommerce::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ecommerce_products_index_url
    assert_response :success
  end

  test "should get show" do
    get ecommerce_products_show_url
    assert_response :success
  end

  test "should get search" do
    get ecommerce_products_search_url
    assert_response :success
  end
end
