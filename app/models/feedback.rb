class Feedback < ApplicationRecord
  KINDS = %w[idee bug temoignage autre].freeze

  belongs_to :user, optional: true

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :body, presence: true, length: { maximum: 5_000 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  after_create_commit :notify_owner, if: :should_notify?

  def should_notify?
    Rails.env.production?
  end

  private

  def notify_owner
    FeedbackMailer.notification(self).deliver_later
  end
end
