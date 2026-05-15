require "test_helper"

class Admin::PitchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_pitches_index_url
    assert_response :success
  end
end
