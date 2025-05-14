require "test_helper"

class Settings::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get settings_passwords_show_url
    assert_response :success
  end

  test "should get update" do
    get settings_passwords_update_url
    assert_response :success
  end
end
