require "test_helper"

class Admin::ClientsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_clients_index_url
    assert_response :success
  end
end
