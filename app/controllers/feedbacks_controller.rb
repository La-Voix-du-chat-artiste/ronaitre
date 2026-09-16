class FeedbacksController < ApplicationController
  layout "public"

  rate_limit to: 5, within: 1.hour, if: -> { request.post? }

  def new
    @feedback = Feedback.new(kind: "idee")
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user if respond_to?(:current_user) && current_user

    if @feedback.save
      redirect_to avis_path, notice: t("feedback.thanks")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.expect(feedback: [ :kind, :email, :body ])
  end
end
