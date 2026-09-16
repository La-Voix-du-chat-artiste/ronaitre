class ConnectionsController < ApplicationController
  layout "app"
  before_action :set_membership, only: %i[update destroy]

  def index
    @memberships = Current.user.owned_memberships.order(created_at: :desc)
    @aidant = Current.user.role == "aidant"
    @tracks = Current.user.tracks.ordered
  end

  def create
    member = User.find_by(email_address: params[:email_address].to_s.strip.downcase)
    kind = Membership::KINDS.include?(params[:kind]) ? params[:kind] : "proche"

    if member.nil?
      return redirect_to connections_path, alert: t("connections.no_account", email: params[:email_address])
    end

    if member.id == Current.user.id
      return redirect_to connections_path, alert: t("connections.self_error")
    end

    membership = Current.user.owned_memberships
                             .where(member: member, kind: kind)
                             .where.not(status: "revoked")
                             .first

    if membership
      return redirect_to connections_path, alert: t("connections.already_connected")
    end

    Current.user.owned_memberships.create!(member: member, kind: kind, status: "invited")
    MembershipsMailer.invitation(membership).deliver_later
    redirect_to connections_path, notice: t("connections.invited", email: member.email_address, kind: t("membership.kinds.#{kind}"))
  end

  def update
    return head :forbidden unless @membership.owner_id == Current.user.id

    update_grants!
    redirect_to connections_path, notice: t("connections.updated")
  end

  def destroy
    return head :forbidden unless @membership.owner_id == Current.user.id

    @membership.update!(status: "revoked")
    redirect_to connections_path, notice: t("connections.revoked", name: @membership.member.email_address)
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

    @membership.update!(status: "active") if @membership.invited? && @membership.grants.any?
  end
end
