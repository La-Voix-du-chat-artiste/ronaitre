class NotificationsController < ApplicationController
  layout "app"

  def index
    @notifications = Current.user.notifications.recent
    Current.user.notifications.unread.update_all(read_at: Time.current)
  end

  def mark_read
    Current.user.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: notifications_path
  end
end
