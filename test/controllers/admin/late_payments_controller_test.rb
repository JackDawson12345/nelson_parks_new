require "test_helper"

class Admin::LatePaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_late_payments_index_url
    assert_response :success
  end
end
