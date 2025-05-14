require "test_helper"

class Settings::NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get settings_notification_preferences_show_url
    assert_response :success
  end

  test "should get update" do
    get settings_notification_preferences_update_url
    assert_response :success
  end
end
