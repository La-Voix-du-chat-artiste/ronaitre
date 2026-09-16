require "test_helper"

class ShareLinksTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email_address: "sharer@example.com", password: "motdepasse1")
    @track = @owner.tracks.create!(name: "Tabac", color: "salmon", quit_at: 20.days.ago)
    @track.consumptions.create!(occurred_at: 1.day.ago, quantity: 2, note: "note privée")
    sign_in_as(@owner)
  end

  test "creates a public link and views are counted" do
    post share_links_path(track_id: @track.id), params: { password: "" }
    share = @track.share_links.last
    assert share.usable?

    sign_out
    assert_no_difference -> { ShareLink.count } do
      get shared_calendar_path(share.token)
      assert_response :success
      get shared_calendar_path(share.token)
    end

    assert_equal 2, share.reload.views_count
    assert_select "h1", text: "Tabac"
    assert_no_match(/note privée/, @response.body)
  end

  test "password-protected link requires the password" do
    post share_links_path(track_id: @track.id), params: { password: "secret123" }
    share = @track.share_links.last

    sign_out
    get shared_calendar_path(share.token)
    assert_response :unauthorized
    assert_select "h1", text: I18n.t("shared_calendar.gate_title")

    post shared_calendar_path(share.token), params: { password: "wrong" }
    assert_response :unauthorized

    post shared_calendar_path(share.token), params: { password: "secret123" }
    assert_redirected_to shared_calendar_path(share.token)

    get shared_calendar_path(share.token)
    assert_response :success
  end

  test "revoked link returns gone" do
    post share_links_path(track_id: @track.id), params: { password: "" }
    share = @track.share_links.last

    delete share_link_path(share)

    sign_out
    get shared_calendar_path(share.token)
    assert_response :gone
  end

  test "another user's track cannot get a share link created" do
    other = User.create!(email_address: "other-sharer@example.com", password: "motdepasse1")
    foreign_track = other.tracks.create!(name: "X", color: "primary", quit_at: 1.day.ago)

    post share_links_path(track_id: foreign_track.id), params: { password: "" }

    assert_response :not_found
  end
end
