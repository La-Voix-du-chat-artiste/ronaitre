class SettingsController < ApplicationController
  layout "app"

  def show
  end

  def update
    if Current.user.update(settings_params)
      redirect_to settings_path, notice: t("settings.updated")
    else
      render :show, status: :unprocessable_entity
    end
  end

  def export
    data = {
      exported_at: Time.current,
      user: Current.user.slice(:email_address, :display_name, :anonymous, :phone),
      tracks: Current.user.tracks.includes(:consumptions, :milestones).map { |track|
        {
          name: track.name,
          color: track.color,
          status: track.status,
          quit_at: track.quit_at,
          personal_best_seconds: track.personal_best_seconds,
          consumptions: track.consumptions.map { |c| c.slice(:occurred_at, :quantity, :unit, :note) },
          milestones: track.milestones.map { |m| m.slice(:label, :seconds, :reached_at) }
        }
      }
    }

    send_data JSON.pretty_generate(data),
              filename: "ronaitre-export-#{Date.current}.json",
              type: "application/json"
  end

  def destroy_account
    Current.user.destroy!
    terminate_session
    reset_session
    redirect_to root_path, notice: t("settings.account_deleted")
  end

  private

  def settings_params
    params.expect(user: [ :display_name, :anonymous, :phone ])
  end
end
