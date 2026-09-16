class ConsumptionsController < ApplicationController
  layout "app"

  def create
    @track = Current.user.tracks.find(params[:track_id])
    @consumption = @track.consumptions.new(consumption_params)

    if @consumption.save
      @track.check_milestones!
      redirect_to track_path(@track), notice: t("consumptions.created")
    else
      redirect_to track_path(@track), alert: t("consumptions.invalid")
    end
  end

  def destroy
    @track = Current.user.tracks.find(params[:track_id])
    @track.consumptions.find(params[:id]).destroy!
    redirect_to track_path(@track), notice: t("consumptions.destroyed")
  end

  private

  def consumption_params
    params.expect(consumption: [ :occurred_at, :quantity, :unit, :note ])
  end
end
