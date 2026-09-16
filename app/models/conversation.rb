class Conversation < ApplicationRecord
  belongs_to :membership
  belongs_to :a, class_name: "User"
  belongs_to :b, class_name: "User"
  has_many :messages, dependent: :destroy

  validates :a_id, uniqueness: { scope: :b_id }
  validate :members_can_converse, on: :create

  scope :involving, ->(user) { where(a: user).or(where(b: user)) }
  scope :recent, -> { order(Arel.sql("last_message_at DESC NULLS LAST, updated_at DESC")) }

  def other_than(user)
    a_id == user.id ? b : a
  end

  def involves?(user)
    [ a_id, b_id ].include?(user&.id)
  end

  def unread_count_for(user)
    messages.where.not(sender: user).where(read_at: nil).count
  end

  def mark_read_for!(user)
    messages.where.not(sender: user).where(read_at: nil).update_all(read_at: Time.current)
  end

  def self.find_for_user!(id, user)
    involving(user).find(id)
  end

  private

  def members_can_converse
    membership = Membership.find_by(id: membership_id)
    return if membership.nil?

    unless membership.status == "active" && membership.grants.where(can_message: true).exists?
      errors.add(:membership, :not_allowed)
    end
  end
end
