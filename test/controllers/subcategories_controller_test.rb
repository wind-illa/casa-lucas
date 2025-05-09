require "test_helper"

class SubcategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get subcategories_index_url
    assert_response :success
  end

  test "should get new" do
    get subcategories_new_url
    assert_response :success
  end

  test "should get create" do
    get subcategories_create_url
    assert_response :success
  end

  test "should get edit" do
    get subcategories_edit_url
    assert_response :success
  end

  test "should get update" do
    get subcategories_update_url
    assert_response :success
  end

  test "should get destroy" do
    get subcategories_destroy_url
    assert_response :success
  end

  test "should get show" do
    get subcategories_show_url
    assert_response :success
  end
end
