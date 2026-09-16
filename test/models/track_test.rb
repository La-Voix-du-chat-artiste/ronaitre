require "test_helper"

class TrackTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "track-user@example.com", password: "motdepasse1")
    Preset.seed!
  end

  test "generates milestones from preset on creation" do
    preset = Preset.find_by!(slug: "tabac")
    track = @user.tracks.create!(name: "Tabac", preset: preset, color: preset.color, quit_at: Time.current)

    assert_equal preset.milestones.size, track.milestones.count
    assert_equal 86_400, track.milestones.minimum(:seconds)
  end

  test "elapsed_seconds grows from quit_at" do
    track = @user.tracks.create!(name: "Test", color: "primary", quit_at: 3.days.ago)

    assert_in_delta 3.days.to_i, track.elapsed_seconds, 5
    assert_equal 3, track.elapsed_days
  end

  test "check_milestones! marks reached milestones with their exact date" do
    track = @user.tracks.create!(name: "Test", color: "primary", quit_at: 8.days.ago)
    track.check_milestones!

    reached = track.milestones.where.not(reached_at: nil)
    assert_equal [ "24 h", "7 jours" ], reached.order(:seconds).pluck(:label)
    assert_in_delta (8.days.ago + 7.days).to_i, reached.order(:seconds).last.reached_at.to_i, 60
  end

  test "restart! preserves personal best and reached milestones" do
    track = @user.tracks.create!(name: "Test", color: "primary", quit_at: 40.days.ago)
    track.check_milestones!
    assert track.milestones.where.not(reached_at: nil).any?

    track.restart!

    assert track.personal_best_seconds > (39.days).to_i

    assert track.reload.milestones.where.not(reached_at: nil).any?
    assert track.active?
    assert_in_delta 0, track.elapsed_seconds, 5
  end

  test "pause and resume keep elapsed time" do
    track = @user.tracks.create!(name: "Test", color: "primary", quit_at: 10.days.ago)
    elapsed_before = track.elapsed_seconds

    track.pause!
    assert track.paused?
    assert_equal elapsed_before, track.elapsed_seconds

    track.resume!
    assert track.active?
    assert_in_delta elapsed_before, track.elapsed_seconds, 5
  end

  test "close! records personal best" do
    track = @user.tracks.create!(name: "Test", color: "primary", quit_at: 15.days.ago)
    track.close!

    assert track.closed?
    assert track.personal_best_seconds > 0
  end
end
