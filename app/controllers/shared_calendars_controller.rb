class SharedCalendarsController < ActionController::Base
  layout "shared"

  def show
    @share = ShareLink.find_by!(token: params[:token])
    return render :revoked, status: :gone unless @share.usable?

    @track = @share.track

    if @share.password_digest.present? && !unlocked?
      return render :password_gate, status: :unauthorized
    end

    @share.register_view!
    @month = parse_month
    @readonly = true
    render :show
  end

  def unlock
    @share = ShareLink.find_by!(token: params[:token])
    return render :revoked, status: :gone unless @share.usable?

    if @share.authenticate(params[:password].to_s)
      session["share_#{@share.id}_unlocked"] = true
      redirect_to shared_calendar_path(@share.token)
    else
      flash.now[:alert] = I18n.t("shared_calendar.wrong_password")
      render :password_gate, status: :unauthorized
    end
  end

  private

  def unlocked?
    session["share_#{@share.id}_unlocked"] == true
  end

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
end
