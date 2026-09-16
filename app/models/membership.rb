class Membership < ApplicationRecord
  KINDS = %w[aidant proche soignant].freeze
  STATUSES = %w[invited active revoked].freeze

  belongs_to :owner, class_name: "User"
  belongs_to :member, class_name: "User", optional: true
  has_many :grants, dependent: :destroy
  has_many :granted_tracks, through: :grants, source: :track

  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }
  validates :owner_id, exclusion: { in: ->(m) { [ m.member_id ].compact }, message: :self_connection }
  validate :member_or_invited_email

  scope :active, -> { where(status: "active") }
  scope :pending, -> { where(status: "invited") }
  scope :owned_by, ->(user) { where(owner: user) }
  scope :involving, ->(user) { where(member: user) }

  before_validation :ensure_invite_token

  def revoked? = status == "revoked"

  def invited? = status == "invited"

  def active? = status == "active"

  def messaging_allowed?
    active? && grants.where(can_message: true).exists?
  end

  def display_name
    member&.display_name.presence || member&.email_address || invited_email
  end

  def attach_member!(user)
    update!(member: user, invited_email: nil)
  end

  private

  def member_or_invited_email
    errors.add(:member, :blank_with_no_email) if member.nil? && invited_email.blank?
  end

  def ensure_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(24)
  end
end
