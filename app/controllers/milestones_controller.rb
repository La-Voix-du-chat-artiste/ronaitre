class MilestonesController < ApplicationController
  layout "app"

  def create
    @track = Current.user.tracks.find(params[:track_id])
    seconds = params.dig(:milestone, :days).to_i * 86_400
    label = params.dig(:milestone, :label).to_s.strip

    if seconds.positive? && label.present? && @track.milestones.where(seconds: seconds).none?
      @track.milestones.create!(label: label[0, 40], seconds: seconds)
      redirect_to track_path(@track), notice: t("milestones.created")
    else
      redirect_to track_path(@track), alert: t("milestones.invalid")
    end
  end

  def destroy
    @track = Current.user.tracks.find(params[:track_id])
    milestone = @track.milestones.find(params[:id])
    milestone.destroy!
    redirect_to track_path(@track), notice: t("milestones.destroyed")
  end
end
