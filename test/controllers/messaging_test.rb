require "test_helper"

class MessagingTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email_address: "msg-owner@example.com", password: "motdepasse1")
    @member = User.create!(email_address: "msg-member@example.com", password: "motdepasse1")
    @outsider = User.create!(email_address: "msg-outsider@example.com", password: "motdepasse1")
    @track = @owner.tracks.create!(name: "Tabac", color: "salmon", quit_at: 10.days.ago)
    @membership = @owner.owned_memberships.create!(member: @member, kind: "proche", status: "active")
    @membership.grants.create!(track: @track, can_message: true)
    @conversation = Conversation.create!(membership: @membership, a: @owner, b: @member)
  end

  test "members see the conversation and can send messages" do
    sign_in_as(@owner)

    get messages_path
    assert_response :success
    assert_select "p.font-bold", text: @member.email_address

    post conversation_messages_path(@conversation), params: { message: { body: "Courage pour aujourd'hui." } }

    assert_redirected_to conversation_path(@conversation)
    assert_equal 1, @conversation.messages.count
    assert_equal "Courage pour aujourd'hui.", @conversation.messages.last.body
  end

  test "unread count decreases after reading" do
    @conversation.messages.create!(sender: @owner, body: "Coucou")

    sign_in_as(@member)
    assert_equal 1, @conversation.unread_count_for(@member)

    get conversation_path(@conversation)
    assert_response :success
    assert_equal 0, @conversation.reload.unread_count_for(@member)
  end

  test "messaging blocked when no can_message grant" do
    @membership.grants.destroy_all

    sign_in_as(@owner)
    post conversation_messages_path(@conversation), params: { message: { body: "test" } }

    assert_response :forbidden
  end

  test "outsider cannot access the conversation" do
    sign_in_as(@outsider)

    get conversation_path(@conversation)
    assert_response :not_found

    post conversation_messages_path(@conversation), params: { message: { body: "intrusion" } }
    assert_response :not_found
  end

  test "email notification is enqueued for the recipient" do
    sign_in_as(@owner)

    assert_enqueued_emails 1 do
      post conversation_messages_path(@conversation), params: { message: { body: "Un mot de soutien." } }
    end
  end
end
