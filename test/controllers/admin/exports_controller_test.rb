require "test_helper"

class Admin::ExportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_exports_index_url
    assert_response :success
  end
end
