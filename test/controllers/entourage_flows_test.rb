require "test_helper"

class EntourageFlowsTest < ActionDispatch::IntegrationTest
  setup do
    Preset.seed!
    @owner = User.create!(email_address: "flow-owner@example.com", password: "motdepasse1")
    @track = @owner.tracks.create!(name: "Tabac", color: "salmon", quit_at: 5.days.ago)
  end

  test "invite a person without an account, they sign up via the token and are connected" do
    sign_in_as(@owner)
    assert_no_difference "User.count" do
      post connections_path, params: { email_address: "future-proche@example.com", kind: "proche" }
    end

    membership = @owner.owned_memberships.last
    assert_nil membership.member
    assert_equal "future-proche@example.com", membership.invited_email

    # L'invité crée son compte puis accepte via le token
    sign_out
    post signup_path, params: { email_address: "future-proche@example.com", password: "motdepasse1", password_confirmation: "motdepasse1" }

    post invitation_path(membership.invite_token)

    membership.reload
    assert membership.active?
    assert_equal User.find_by(email_address: "future-proche@example.com").id, membership.member_id
  end

  test "whole-account share link shows all tracks and counts a notification" do
    sign_in_as(@owner)
    post share_links_path, params: { password: "" }
    share = @owner.share_links.last
    assert_nil share.track

    sign_out
    get shared_calendar_path(share.token)
    assert_response :success
    assert_match "Tabac", @response.body
    assert_equal 1, @owner.notifications.where(event: "share_viewed").count
  end

  test "suivi requests an aidant, aidant accepts from dashboard" do
    aidant = User.create!(email_address: "aidant@example.com", password: "motdepasse1", role: "aidant", bio: "Ancien accompagnant CSAPA")

    sign_in_as(@owner)
    post request_aidant_path(aidant)

    membership = @owner.owned_memberships.last
    assert_equal "aidant", membership.kind
    assert_equal "invited", membership.status
    assert_equal 1, aidant.notifications.where(event: "invitation").count

    sign_out
    sign_in_as(aidant)
    get helper_dashboard_path
    assert_response :success

    post accept_membership_path(membership)
    membership.reload
    assert membership.active?
  end

  test "signup can create an aidant account" do
    post signup_path, params: { email_address: "new-aidant@example.com", password: "motdepasse1", password_confirmation: "motdepasse1", role: "aidant" }

    assert_redirected_to dashboard_path
    assert_equal "aidant", User.find_by!(email_address: "new-aidant@example.com").role
  end
end
