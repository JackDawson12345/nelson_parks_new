require "test_helper"

class Admin::UtilitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_utilities_index_url
    assert_response :success
  end
end
