class Grant < ApplicationRecord
  belongs_to :membership
  belongs_to :track

  validates :track_id, uniqueness: { scope: :membership_id }
end
