class ChatMessage < ApplicationRecord
  ROLES = %w[user assistant system].freeze

  belongs_to :chat_thread

  validates :role, inclusion: { in: ROLES }
  validates :content, presence: true, length: { maximum: 4_000 }

  scope :chronological, -> { order(:created_at) }
end
