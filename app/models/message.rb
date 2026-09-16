class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true, length: { maximum: 2_000 }

  after_create_commit :broadcast_and_notify

  scope :chronological, -> { order(:created_at) }

  def broadcast_and_notify
    broadcast_message
    notify_recipient
  end

  private

  def broadcast_message
    broadcast_append_to(
      [ :conversation, conversation_id ],
      target: "messages",
      partial: "messages/message",
      locals: { message: self }
    )
    conversation.update!(last_message_at: created_at)
  end

  def notify_recipient
    recipient = conversation.other_than(sender)
    return if recipient.id == sender.id

    Notification.deliver!(recipient, "new_message", { message: I18n.t("notifications.new_message", name: sender.display_name.presence || I18n.t("helper.anonymous_person")) })

    if NotificationPref.allowed?(recipient, "new_message", :email)
      MessagesMailer.new_message(self, recipient).deliver_later
    end

    return unless NotificationPref.allowed?(recipient, "new_message", :sms)

    result = SmsGateway.send!(recipient.phone, I18n.t("notifications.new_message_sms", name: sender.display_name.presence || "Ronaitre"))
    Rails.logger.warn("[sms] send failed: #{result.error}") unless result.success?
  end
end
