require "test_helper"

class Admin::PitchFeesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_pitch_fees_index_url
    assert_response :success
  end
end
