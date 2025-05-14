require "test_helper"

class Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get settings_profiles_show_url
    assert_response :success
  end

  test "should get update" do
    get settings_profiles_update_url
    assert_response :success
  end
end
