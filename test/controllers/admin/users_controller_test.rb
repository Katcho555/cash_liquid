require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_users_index_url
    assert_response :success
  end

  test "should get edit" do
    get admin_users_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_users_update_url
    assert_response :success
  end

  test "should get block" do
    get admin_users_block_url
    assert_response :success
  end

  test "should get unblock" do
    get admin_users_unblock_url
    assert_response :success
  end
end
