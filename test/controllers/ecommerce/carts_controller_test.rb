require "test_helper"

class Ecommerce::CartsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get ecommerce_carts_show_url
    assert_response :success
  end

  test "should get update" do
    get ecommerce_carts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get ecommerce_carts_destroy_url
    assert_response :success
  end

  test "should get add" do
    get ecommerce_carts_add_url
    assert_response :success
  end

  test "should get remove" do
    get ecommerce_carts_remove_url
    assert_response :success
  end
end
