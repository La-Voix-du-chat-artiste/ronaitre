class ShareLinksController < ApplicationController
  layout "app"

  def create
    @track = Current.user.tracks.find(params[:track_id]) if params[:track_id].present?
    share = Current.user.share_links.new(track: @track)
    share.password = params[:password].presence

    if share.save
      redirect_back fallback_location: dashboard_path(anchor: "partage"), notice: t("share_links.created")
    else
      redirect_back fallback_location: dashboard_path(anchor: "partage"), alert: t("share_links.invalid")
    end
  end

  def destroy
    share = Current.user.share_links.find(params[:id])
    share.revoke!
    redirect_back fallback_location: dashboard_path(anchor: "partage"), notice: t("share_links.revoked")
  end
end
