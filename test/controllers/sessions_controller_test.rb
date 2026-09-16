require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "renders sign in page" do
    get auth_path
    assert_response :success
    assert_select "h1", text: I18n.t("auth.signin_title")
  end

  test "renders sign up page in signup mode" do
    get signup_path
    assert_response :success
    assert_select "h1", text: I18n.t("auth.signup_title")
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to auth_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end
end
