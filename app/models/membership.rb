class Membership < ApplicationRecord
  KINDS = %w[aidant proche soignant].freeze
  STATUSES = %w[invited active revoked].freeze

  belongs_to :owner, class_name: "User"
  belongs_to :member, class_name: "User"
  has_many :grants, dependent: :destroy
  has_many :granted_tracks, through: :grants, source: :track

  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }
  validates :owner_id, exclusion: { in: ->(m) { [ m.member_id ] }, message: :self_connection }

  scope :active, -> { where(status: "active") }
  scope :pending, -> { where(status: "invited") }
  scope :owned_by, ->(user) { where(owner: user) }
  scope :involving, ->(user) { where(member: user) }

  generates_token_for :accept, expires_in: 30.days

  before_validation :ensure_invite_token

  def revoked? = status == "revoked"

  def invited? = status == "invited"

  def active? = status == "active"

  def messaging_allowed?
    active? && grants.where(can_message: true).exists?
  end

  private

  def ensure_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(24)
  end
end
