class ShareLink < ApplicationRecord
  belongs_to :user
  belongs_to :track

  has_secure_password validations: false

  validates :token, presence: true, uniqueness: true

  scope :active, -> { where(revoked_at: nil) }
  scope :unexpired, -> { where(expires_at: nil).or(where(expires_at: ..Time.current)) }

  before_validation :ensure_token

  def revoked? = revoked_at.present?

  def expired? = expires_at.present? && expires_at < Time.current

  def usable? = !revoked? && !expired?

  def register_view!
    increment!(:views_count)
    touch(:last_viewed_at)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  private

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end
end
