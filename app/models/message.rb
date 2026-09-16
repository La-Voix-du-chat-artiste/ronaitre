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

    MessagesMailer.new_message(self, recipient).deliver_later
  end
end
