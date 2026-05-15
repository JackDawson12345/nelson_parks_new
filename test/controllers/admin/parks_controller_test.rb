require "test_helper"

class Admin::ParksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_parks_index_url
    assert_response :success
  end
end
