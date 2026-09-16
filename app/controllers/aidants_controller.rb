class AidantsController < ApplicationController
  layout "public"
  before_action :require_authentication, only: :request_help

  def index
    @aidants = User.where(role: "aidant").order(:created_at).limit(50)
    @requested_ids = authenticated? ? Current.user.owned_memberships.pending.where(kind: "aidant").pluck(:member_id) : []
  end

  def request_help
    aidant = User.aidants.find(params[:id])

    if aidant.id == Current.user.id
      return redirect_to aidants_path, alert: t("aidants.self_request")
    end

    existing = Current.user.owned_memberships.where(member: aidant, kind: "aidant").where.not(status: "revoked").first
    if existing
      return redirect_to aidants_path, alert: t("aidants.already_requested")
    end

    membership = Current.user.owned_memberships.create!(member: aidant, kind: "aidant", status: "invited")
    Notification.deliver!(aidant, "invitation", { message: t("notifications.aidant_request") })
    Rails.logger.info("[aidants] request ##{membership.id} from #{Current.user.id} to #{aidant.id}")

    redirect_to aidants_path, notice: t("aidants.requested")
  end
end
