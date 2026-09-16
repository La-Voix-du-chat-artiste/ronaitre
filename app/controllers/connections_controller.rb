class ConnectionsController < ApplicationController
  layout "app"
  before_action :set_membership, only: %i[update destroy]

  def index
    @memberships = Current.user.owned_memberships.order(created_at: :desc)
    @tracks = Current.user.tracks.ordered
  end

  def create
    email = params[:email_address].to_s.strip.downcase
    kind = Membership::KINDS.include?(params[:kind]) ? params[:kind] : "proche"

    if email.blank?
      return redirect_to connections_path, alert: t("connections.email_blank")
    end

    if email == Current.user.email_address
      return redirect_to connections_path, alert: t("connections.self_error")
    end

    member = User.find_by(email_address: email)
    existing = Current.user.owned_memberships
                          .where("member_id = ? OR invited_email = ?", member&.id, email)
                          .where(kind: kind)
                          .where.not(status: "revoked")
                          .first

    if existing
      return redirect_to connections_path, alert: t("connections.already_connected")
    end

    membership = Current.user.owned_memberships.create!(member: member, invited_email: member.nil? ? email : nil, kind: kind, status: "invited")
    MembershipsMailer.invitation(membership).deliver_later

    notice_key = member.nil? ? "connections.invited_no_account" : "connections.invited"
    redirect_to connections_path, notice: t(notice_key, email: email, kind: t("membership.kinds.#{kind}"))
  end

  def update
    return head :forbidden unless @membership.owner_id == Current.user.id

    update_grants!
    redirect_to connections_path, notice: t("connections.updated")
  end

  def destroy
    return head :forbidden unless @membership.owner_id == Current.user.id

    @membership.update!(status: "revoked")
    Notification.deliver!(@membership.member, "grant_change", { message: t("notifications.revoked_by_owner") }) if @membership.member
    redirect_to connections_path, notice: t("connections.revoked", name: @membership.display_name)
  end

  private

  def set_membership
    @membership = Current.user.owned_memberships.find(params[:id])
  end

  def update_grants!
    grants_params = params[:grants] || {}
    can_message = params[:can_message] == "1"

    Current.user.tracks.find_each do |track|
      selected = grants_params[track.id.to_s] == "1"
      grant = @membership.grants.find_by(track: track)

      if selected && grant.nil?
        @membership.grants.create!(track: track, can_view_details: params.dig(:details, track.id.to_s) == "1", can_message: can_message)
      elsif selected && grant
        grant.update!(can_view_details: params.dig(:details, track.id.to_s) == "1", can_message: can_message)
      elsif !selected && grant
        grant.destroy!
      end
    end

    if @membership.invited? && @membership.grants.any?
      @membership.update!(status: "active")
      Notification.deliver!(@membership.member, "grant_change", { message: t("notifications.granted_by_owner") }) if @membership.member
    end
  end
end
