require "application_system_test_case"

class LandingsTest < ApplicationSystemTestCase
  test "visitor signs up from the landing page" do
    visit root_url

    assert_selector "h1", text: "Suivez votre progrès, jour après jour."
    assert_selector "header nav"
    assert_selector "footer"

    click_on "Commencer gratuitement", match: :first

    assert_selector "h1", text: I18n.t("auth.signup_title")

    fill_in "E-mail", with: "systeme@example.com"
    fill_in "Mot de passe", with: "motdepasse1", match: :prefer_exact
    fill_in "Confirmer le mot de passe", with: "motdepasse1"

    click_on I18n.t("auth.signup_submit")

    assert_text I18n.t("auth.welcome")
  end

  test "faq accordions expand" do
    visit root_url
    first("#faq details summary").click
    assert_selector "#faq details[open]"
  end
end
