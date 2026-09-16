class ChatThread < ApplicationRecord
  belongs_to :user
  has_many :chat_messages, dependent: :destroy

  scope :for_user, ->(user) { where(user: user) }

  def self.current_for(user)
    find_or_create_by!(user: user)
  end
end
