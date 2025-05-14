require "test_helper"

class Settings::BackupsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get settings_backups_show_url
    assert_response :success
  end

  test "should get create" do
    get settings_backups_create_url
    assert_response :success
  end
end
