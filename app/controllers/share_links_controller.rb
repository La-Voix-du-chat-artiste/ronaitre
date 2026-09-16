class ShareLinksController < ApplicationController
  layout "app"

  def create
    @track = Current.user.tracks.find(params[:track_id])
    share = @track.share_links.new(user: Current.user)
    share.password = params[:password].presence

    if share.save
      redirect_to track_path(@track, anchor: "partage"), notice: t("share_links.created")
    else
      redirect_to track_path(@track, anchor: "partage"), alert: t("share_links.invalid")
    end
  end

  def destroy
    @track = Current.user.tracks.find(params[:track_id])
    share = @track.share_links.find(params[:id])
    share.revoke!
    redirect_to track_path(@track, anchor: "partage"), notice: t("share_links.revoked")
  end
end
