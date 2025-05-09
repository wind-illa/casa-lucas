require "test_helper"

class Ecommerce::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get ecommerce_orders_new_url
    assert_response :success
  end

  test "should get create" do
    get ecommerce_orders_create_url
    assert_response :success
  end

  test "should get show" do
    get ecommerce_orders_show_url
    assert_response :success
  end

  test "should get shipping" do
    get ecommerce_orders_shipping_url
    assert_response :success
  end

  test "should get choose_shipping" do
    get ecommerce_orders_choose_shipping_url
    assert_response :success
  end

  test "should get payment" do
    get ecommerce_orders_payment_url
    assert_response :success
  end

  test "should get choose_payment" do
    get ecommerce_orders_choose_payment_url
    assert_response :success
  end

  test "should get review" do
    get ecommerce_orders_review_url
    assert_response :success
  end

  test "should get confirm" do
    get ecommerce_orders_confirm_url
    assert_response :success
  end
end
