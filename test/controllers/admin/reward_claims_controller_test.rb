require "test_helper"

class Admin::RewardClaimsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_reward_claims_index_url
    assert_response :success
  end
end
