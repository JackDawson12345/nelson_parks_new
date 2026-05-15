require "test_helper"

class Manage::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_dashboard_index_url
    assert_response :success
  end
end
