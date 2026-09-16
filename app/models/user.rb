class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :owned_memberships, class_name: "Membership", foreign_key: :owner_id, dependent: :destroy
  has_many :memberships_involving, class_name: "Membership", foreign_key: :member_id, dependent: :destroy
  has_many :share_links, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :role, inclusion: { in: %w[suivi aidant] }
end
