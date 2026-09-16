class TracksController < ApplicationController
  layout "app"
  before_action :set_track, only: %i[show edit update destroy pause resume restart close calendar]
  before_action :ensure_preset_seeded, only: :new
  before_action :require_owner, only: %i[edit update destroy pause resume restart close]

  def index
    @active_tracks = Current.user.tracks.active.ordered
    @other_tracks = Current.user.tracks.where.not(status: :active).ordered
  end

  def show
    authorize_view!
    @track.check_milestones!
    @policy = TrackPolicy.new(Current.user, @track)
    @consumption = @policy.owner? ? Consumption.new : nil
    @recent_consumptions = @policy.visible_consumptions.order(occurred_at: :desc).limit(10)
  end

  def calendar
    authorize_view!
    @month = parse_month
    render partial: "calendar"
  end

  def new
    @track = Current.user.tracks.new(quit_at: Time.current)
    @presets = Preset.active
  end

  def create
    @track = Current.user.tracks.new(track_params)
    apply_preset_defaults

    if @track.save
      redirect_to track_path(@track), notice: t("tracks.created", name: @track.name)
    else
      @presets = Preset.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @presets = Preset.active
  end

  def update
    if @track.update(update_params)
      redirect_to track_path(@track), notice: t("tracks.updated")
    else
      @presets = Preset.active
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @track.destroy!
    redirect_to dashboard_path, notice: t("tracks.destroyed")
  end

  def pause
    @track.pause!
    redirect_to track_path(@track), notice: t("tracks.paused")
  end

  def resume
    @track.resume!
    redirect_to track_path(@track), notice: t("tracks.resumed")
  end

  def restart
    @track.restart!
    redirect_to track_path(@track), notice: t("tracks.restarted")
  end

  def close
    @track.close!
    redirect_to dashboard_path, notice: t("tracks.closed", best: @track.personal_best_seconds / 86_400)
  end

  private

  def parse_month
    ym = params[:ym].to_s
    if ym.match?(/\A\d{4}-\d{2}\z/)
      year, month = ym.split("-").map(&:to_i)
      Date.new(year, month, 1)
    else
      Date.current.beginning_of_month
    end
  rescue Date::Error
    Date.current.beginning_of_month
  end

  def set_track
    @track = Track.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ActiveRecord::RecordNotFound
  end

  def authorize_view!
    return if TrackPolicy.new(Current.user, @track).view?

    raise ActiveRecord::RecordNotFound
  end

  def require_owner
    return if @track.user_id == Current.user.id

    redirect_to dashboard_path, alert: t("tracks.owner_only")
  end

  def track_params
    params.expect(track: [ :name, :preset_id, :color, :quit_at ])
  end

  def update_params
    params.expect(track: [ :name, :color ])
  end

  def apply_preset_defaults
    preset_id = params.dig(:track, :preset_id)
    if preset_id.present? && preset_id != "custom"
      preset = Preset.find(preset_id)
      @track.preset = preset
      @track.color = preset.color if @track.color.blank?
    else
      @track.preset = nil
    end
  end

  def ensure_preset_seeded
    Preset.seed! if Preset.active.empty?
  end
end
