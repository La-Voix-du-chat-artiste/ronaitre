require "test_helper"

class NotificationPrefsTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email_address: "prefs-owner@example.com", password: "motdepasse1")
    @member = User.create!(email_address: "prefs-member@example.com", password: "motdepasse1")
    @track = @owner.tracks.create!(name: "Tabac", color: "salmon", quit_at: 10.days.ago)
    @membership = @owner.owned_memberships.create!(member: @member, kind: "proche", status: "active")
    @membership.grants.create!(track: @track, can_message: true)
    @conversation = Conversation.create!(membership: @membership, a: @owner, b: @member)
  end

  test "message email respects email=false preference" do
    NotificationPref.create!(user: @member, event: "new_message", email: false, sms: false)

    sign_in_as(@owner)
    assert_no_enqueued_emails do
      post conversation_messages_path(@conversation), params: { message: { body: "Coucou" } }
    end

    assert_equal 1, @member.notifications.count
  end

  test "milestone sweep respects in_app=false and sms=true" do
    NotificationPref.create!(user: @owner, event: "milestone_reached", in_app: false, email: true, sms: true)
    @owner.update!(phone: "+33612345678")
    @track.update!(quit_at: 8.days.ago)

    Milestones::SweepJob.perform_now

    assert_equal 0, @owner.notifications.count
    assert_enqueued_emails 2
  end

  test "milestone email sent when prefs allow" do
    NotificationPref.create!(user: @owner, event: "milestone_reached", in_app: true, email: true)
    @track.update!(quit_at: 8.days.ago)

    assert_enqueued_emails 2 do
      Milestones::SweepJob.perform_now
    end

    assert_equal 2, @owner.notifications.count
  end
end
