require "test_helper"

class Admin::InvoiceBatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_invoice_batches_index_url
    assert_response :success
  end
end
