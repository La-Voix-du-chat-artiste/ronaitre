class InvitationsController < ApplicationController
  layout "app"

  def show
    @membership = Membership.find_by!(invite_token: params[:token])
    head :gone if @membership.revoked?
  end

  def accept_by_token
    @membership = Membership.find_by!(invite_token: params[:token])
    head :gone if @membership.revoked?

    if @membership.member_id != Current.user.id
      return redirect_to root_path, alert: t("invitations.wrong_account", email: @membership.member.email_address)
    end

    @membership.update!(status: "active")
    redirect_to helper_dashboard_path, notice: t("invitations.accepted")
  end

  def accept
    @membership = Current.user.memberships_involving.find(params[:id])
    @membership.update!(status: "active")
    redirect_to helper_dashboard_path, notice: t("invitations.accepted")
  end

  def decline
    @membership = Current.user.memberships_involving.find(params[:id])
    @membership.update!(status: "revoked")
    redirect_to helper_dashboard_path, notice: t("invitations.declined")
  end
end
