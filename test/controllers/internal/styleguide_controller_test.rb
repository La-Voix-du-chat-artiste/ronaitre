require "test_helper"

module Internal
  class StyleguideControllerTest < ActionDispatch::IntegrationTest
    test "renders styleguide with design tokens in dev/test" do
      get styleguide_url
      assert_response :success
      assert_select "h1", /Styleguide/
    end

    test "home renders hero with french copy and preserved skin" do
      get root_url
      assert_response :success
      assert_select "html[lang=fr]"
      assert_select "h1", text: "Suivez votre progrès, jour après jour."
    end
  end
end
