require "test_helper"

class ConnectionsSecurityTest < ActionDispatch::IntegrationTest
  setup do
    Preset.seed!
    @owner = User.create!(email_address: "owner@example.com", password: "motdepasse1")
    @member = User.create!(email_address: "member@example.com", password: "motdepasse1")
    @outsider = User.create!(email_address: "outsider@example.com", password: "motdepasse1")
    @track = @owner.tracks.create!(name: "Tabac", color: "salmon", quit_at: 10.days.ago)
    @track.consumptions.create!(occurred_at: 1.day.ago, quantity: 3, note: "soirée difficile")
    sign_in_as(@owner)
  end

  test "invite, accept and grant counter+calendar only" do
    post connections_path, params: { email_address: @member.email_address, kind: "proche" }
    assert_redirected_to connections_path

    membership = @owner.owned_memberships.last
    patch connection_path(membership), params: { grants: { @track.id.to_s => "1" }, can_message: "1" }

    membership.reload
    assert membership.active?
    assert_equal [ @track.id ], membership.granted_tracks.ids
    assert_not membership.grants.first.can_view_details
  end

  test "member sees counter and calendar but NOT consumption notes" do
    membership = @owner.owned_memberships.create!(member: @member, kind: "proche", status: "active")
    membership.grants.create!(track: @track, can_view_details: false)

    sign_out
    sign_in_as(@member)

    get track_path(@track)
    assert_response :success
    assert_select "h1", text: "Tabac"
    assert_no_match(/soirée difficile/, @response.body)
  end

  test "grant with details allows notes" do
    membership = @owner.owned_memberships.create!(member: @member, kind: "soignant", status: "active")
    membership.grants.create!(track: @track, can_view_details: true)

    sign_out
    sign_in_as(@member)

    get track_path(@track)
    assert_response :success
    assert_match "soirée difficile", @response.body
  end

  test "revocation removes access immediately" do
    membership = @owner.owned_memberships.create!(member: @member, kind: "proche", status: "active")
    membership.grants.create!(track: @track)

    sign_out
    sign_in_as(@member)
    get track_path(@track)
    assert_response :success

    sign_out
    sign_in_as(@owner)
    delete connection_path(membership)
    membership.reload
    assert membership.revoked?

    sign_out
    sign_in_as(@member)
    get track_path(@track)
    assert_response :not_found
  end

  test "outsider cannot see the track at all" do
    sign_out
    sign_in_as(@outsider)

    get track_path(@track)
    assert_response :not_found
  end

  test "member cannot grant themselves more access" do
    membership = @owner.owned_memberships.create!(member: @member, kind: "proche", status: "active")

    sign_out
    sign_in_as(@member)
    patch connection_path(membership), params: { grants: { @track.id.to_s => "1" }, details: { @track.id.to_s => "1" } }

    assert_response :not_found
  end
end
