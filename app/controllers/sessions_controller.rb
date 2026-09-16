class SessionsController < ApplicationController
  layout "public"
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 5, within: 3.minutes, only: :create,
             with: -> { redirect_to auth_path, alert: t("auth.rate_limited") }

  def new
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      start_new_session_for user
      redirect_to after_authentication_url, notice: t("auth.signed_in")
    else
      redirect_to auth_path, alert: t("auth.invalid_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: t("auth.signed_out")
  end
end
