module Milestones
  class SweepJob < ApplicationJob
    queue_as :default

    def perform
      Track.active.includes(:user, :milestones).find_each do |track|
        newly_reached = track.check_milestones_with_notification!
        next if newly_reached.empty?

        newly_reached.each do |milestone|
          notify_followers(track, milestone)
        end
        Rails.logger.info("[milestones] track##{track.id} reached: #{newly_reached.map(&:label).join(', ')}")
      end
    end

    private

    def notify_followers(track, milestone)
      user = track.user
      payload = { message: I18n.t("notifications.milestone", label: milestone.label, name: track.name) }

      Notification.deliver!(user, "milestone_reached", payload) if NotificationPref.allowed?(user, "milestone_reached", :in_app)

      if NotificationPref.allowed?(user, "milestone_reached", :email)
        NotificationsMailer.milestone(user, track, milestone).deliver_later
      end

      if NotificationPref.allowed?(user, "milestone_reached", :sms) && user.phone.present?
        SmsGateway.send!(user.phone, I18n.t("notifications.milestone_sms", label: milestone.label))
      end

      granted_users = User.joins(memberships_involving: :grants)
                          .where(memberships: { owner_id: user.id, status: "active" }, grants: { track_id: track.id })
                          .distinct
      granted_users.find_each do |follower|
        Notification.deliver!(follower, "milestone_reached", payload) if NotificationPref.allowed?(follower, "milestone_reached", :in_app)
      end
    end
  end
end
