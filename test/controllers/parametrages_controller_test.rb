require "test_helper"

class ParametragesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get parametrages_show_url
    assert_response :success
  end

  test "should get update" do
    get parametrages_update_url
    assert_response :success
  end
end
