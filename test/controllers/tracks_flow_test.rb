require "test_helper"

class TracksFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "flow@example.com", password: "motdepasse1")
    Preset.seed!
    sign_in_as(@user)
  end

  test "dashboard shows onboarding when no track" do
    get dashboard_path
    assert_response :success
    assert_select "h2", text: I18n.t("onboarding.title")
  end

  test "creates a track from preset and shows live counter" do
    preset = Preset.find_by!(slug: "tabac")

    assert_difference "Track.count", 1 do
      assert_difference "Milestone.count", preset.milestones.size do
        post tracks_path, params: { track: { name: "Tabac", preset_id: preset.id, quit_at: 2.days.ago.iso8601 } }
      end
    end

    assert_redirected_to track_path(Track.last)
    follow_redirect!
    assert_select "h1", text: "Tabac"
    assert_select "[data-controller=live-counter]"
  end

  test "logging a consumption never resets the counter" do
    track = @user.tracks.create!(name: "Tabac", color: "salmon", quit_at: 10.days.ago)
    quit_at = track.reload.quit_at

    post track_consumptions_path(track), params: { consumption: { occurred_at: Time.current.iso8601, quantity: "2", unit: "cigarettes" } }

    assert_redirected_to track_path(track)
    assert_in_delta quit_at.to_i, track.reload.quit_at.to_i, 1
    assert_equal 1, track.consumptions.count
  end

  test "explicit restart resets quit_at but keeps personal best" do
    track = @user.tracks.create!(name: "Tabac", color: "salmon", quit_at: 40.days.ago)

    post restart_track_path(track)

    track.reload
    assert track.quit_at > 1.minute.ago
    assert track.personal_best_seconds > (39.days).to_i
  end

  test "calendar marks slip days" do
    track = @user.tracks.create!(name: "Tabac", color: "salmon", quit_at: 5.days.ago)
    track.consumptions.create!(occurred_at: 2.days.ago)

    get calendar_track_path(track, ym: Date.current.strftime("%Y-%m")), headers: { "Accept" => "text/vnd.turbo-stream.html, text/html" }

    assert_response :success
    assert_match "destructive", @response.body
  end

  test "exports own data as json" do
    track = @user.tracks.create!(name: "Tabac", color: "salmon", quit_at: 5.days.ago)
    track.consumptions.create!(occurred_at: 2.days.ago, quantity: 1)

    get export_settings_path

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 1, json["tracks"].size
    assert_equal 1, json["tracks"].first["consumptions"].size
  end

  test "account deletion cascades and signs out" do
    track = @user.tracks.create!(name: "Tabac", color: "salmon", quit_at: 5.days.ago)

    assert_difference "User.count", -1 do
      assert_difference "Track.count", -1 do
        delete destroy_account_settings_path
      end
    end

    assert_redirected_to root_path
    assert_raises(ActiveRecord::RecordNotFound) { track.reload }
  end

  test "cannot access another user's track" do
    other = User.create!(email_address: "other@example.com", password: "motdepasse1")
    foreign_track = other.tracks.create!(name: "Secret", color: "primary", quit_at: 1.day.ago)

    get track_path(foreign_track)

    assert_response :not_found
  end
end
