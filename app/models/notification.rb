class Notification < ApplicationRecord
  belongs_to :user

  validates :event, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(30) }

  def self.deliver!(user, event, payload = {})
    return unless NotificationPref.allowed?(user, event, :in_app)

    user.notifications.create!(event: event, payload: payload)
  end
end
