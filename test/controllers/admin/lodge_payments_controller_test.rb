require "test_helper"

class Admin::LodgePaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_lodge_payments_index_url
    assert_response :success
  end
end
