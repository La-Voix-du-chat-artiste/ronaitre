require "application_system_test_case"

class TechnicalSurfacesTest < ApplicationSystemTestCase
  test "chat crisis flow + csapa + settings prefs visible" do
    Rails.cache.clear
    Preset.seed!
    user = User.create!(email_address: "tech@example.com", password: "motdepasse1")

    visit auth_url
    fill_in "E-mail", with: user.email_address
    fill_in "Mot de passe", with: "motdepasse1"
    click_button I18n.t("auth.signin_submit")
    assert_selector "h1", text: "Mes suivis"

    # Chat
    visit chat_url
    fill_in "chat_message_content", with: "J'ai du mal ce soir, grosse envie."
    click_button I18n.t("chat.send")
    assert_selector "#chat-messages > div", minimum: 2

    # Crisis
    fill_in "chat_message_content", with: "parfois je pense au suicide"
    click_button I18n.t("chat.send")
    assert_text "3114"
    page.save_screenshot(Rails.root.join("../tmp/chat-crisis.png"), full_page: false)

    # CSAPA
    CsapaFacility.create!(name: "CSAPA Paris Bastille", address: "12 rue de la Roquette", zip: "75011", city: "Paris", dept: "75", phone: "01 43 55 12 34")
    visit csapa_url
    assert_text "CSAPA Paris Bastille"
    page.save_screenshot(Rails.root.join("../tmp/csapa.png"))

    # Settings prefs
    visit settings_url
    assert_selector "h2", text: I18n.t("settings.notifications")
    page.save_screenshot(Rails.root.join("../tmp/settings-prefs.png"))
  end
end
