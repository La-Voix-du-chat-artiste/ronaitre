class TrackPolicy
  def initialize(user, track)
    @user = user
    @track = track
  end

  def owner?
    @track.user_id == @user&.id
  end

  def view?
    owner? || granted?
  end

  def view_details?
    owner? || (granted? && active_grant&.can_view_details)
  end

  def granted?
    active_grant.present?
  end

  def active_grant
    @active_grant ||= Grant.joins(:membership)
                           .where(track: @track, memberships: { member_id: @user&.id, status: "active" })
                           .first
  end

  def visible_consumptions
    return @track.consumptions if owner? || view_details?

    @track.consumptions.none
  end
end
