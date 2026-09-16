require "application_system_test_case"

class ScreenshotsTest < ApplicationSystemTestCase
  test "capture dashboard and track page" do
    Preset.seed!
    user = User.create!(email_address: "shots@example.com", password: "motdepasse1")
    track = user.tracks.create!(name: "Tabac", color: "salmon", quit_at: 47.days.ago, personal_best_seconds: 30.days.to_i)
    track.consumptions.create!(occurred_at: 2.days.ago, quantity: 2, unit: "cigarettes")
    track.check_milestones!

    visit auth_url
    fill_in "E-mail", with: user.email_address
    fill_in "Mot de passe", with: "motdepasse1"
    click_button I18n.t("auth.signin_submit")

    assert_selector "h1", text: "Mes suivis"
    page.save_screenshot(Rails.root.join("../tmp/dashboard.png"), full_page: false)

    visit track_url(track)
    assert_selector "h1", text: "Tabac"
    page.save_screenshot(Rails.root.join("../tmp/track-page.png"), full_page: false)
  end
end
