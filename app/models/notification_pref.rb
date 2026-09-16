class NotificationPref < ApplicationRecord
  EVENTS = %w[milestone_reached consumption_logged new_message invitation grant_change share_viewed].freeze
  CHANNELS = %i[in_app email sms].freeze

  belongs_to :user

  validates :event, presence: true, inclusion: { in: EVENTS }
  validates :user_id, uniqueness: { scope: :event }

  def self.ensure_defaults_for!(user)
    EVENTS.each { |event| find_or_create_by!(user: user, event: event) }
  end

  def self.allowed?(user, event, channel)
    pref = user.notification_prefs.find_by(event: event)
    pref.nil? || pref.public_send(channel)
  end
end
