require "test_helper"

class Manage::InvoicesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_invoices_index_url
    assert_response :success
  end
end
