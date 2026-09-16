class RegistrationsController < ApplicationController
  layout "public"
  allow_unauthenticated_access only: :create
  rate_limit to: 5, within: 1.hour, only: :create,
             with: -> { redirect_to signup_path, alert: t("auth.rate_limited") }

  def create
    @user = User.new(email_address: params[:email_address], password: params[:password], password_confirmation: params[:password_confirmation])

    if @user.save
      start_new_session_for @user
      redirect_to dashboard_path, notice: t("auth.welcome")
    else
      redirect_to signup_path, alert: @user.errors.full_messages.to_sentence
    end
  end
end
