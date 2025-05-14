require "test_helper"

class Settings::AccountSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get settings_account_settings_show_url
    assert_response :success
  end

  test "should get update" do
    get settings_account_settings_update_url
    assert_response :success
  end
end
