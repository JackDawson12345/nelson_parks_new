require "test_helper"

class Admin::InvoicesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_invoices_index_url
    assert_response :success
  end
end
