require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "creates an account and signs in" do
    assert_difference "User.count", 1 do
      post signup_path, params: {
        email_address: "nouveau@example.com",
        password: "motdepasse1",
        password_confirmation: "motdepasse1"
      }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "rejects short password" do
    assert_no_difference "User.count" do
      post signup_path, params: {
        email_address: "court@example.com",
        password: "court",
        password_confirmation: "court"
      }
    end

    assert_redirected_to signup_path
  end

  test "rejects duplicate email" do
    User.create!(email_address: "existant@example.com", password: "motdepasse1")

    assert_no_difference "User.count" do
      post signup_path, params: {
        email_address: "existant@example.com",
        password: "motdepasse1",
        password_confirmation: "motdepasse1"
      }
    end

    assert_redirected_to signup_path
  end
end
