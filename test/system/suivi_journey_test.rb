require "application_system_test_case"

class SuiviJourneyTest < ApplicationSystemTestCase
  test "full journey: signup, create track, log slip without reset, see calendar" do
    Preset.seed!

    visit signup_url
    fill_in "E-mail", with: "parcours@example.com"
    fill_in "Mot de passe", with: "motdepasse1", match: :prefer_exact
    fill_in "Confirmer le mot de passe", with: "motdepasse1"
    click_on I18n.t("auth.signup_submit")

    assert_text I18n.t("onboarding.title")
    click_on I18n.t("onboarding.cta")

    assert_selector "h1", text: I18n.t("tracks.new_title")
    find("[data-track-preset-slug-value=tabac]").click
    fill_in "Nom du suivi", with: "Tabac"
    click_on I18n.t("tracks.create_submit")

    assert_text I18n.t("tracks.created", name: "Tabac")
    assert_selector "[data-controller=live-counter]"

    fill_in "Quantité", with: "2"
    click_on I18n.t("consumptions.submit")

    assert_text I18n.t("consumptions.created")
    assert_selector "[data-controller=live-counter]"

    click_on I18n.t("nav.sign_out")
    assert_selector "h1"
  end
end
