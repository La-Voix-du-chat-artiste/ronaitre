class Milestone < ApplicationRecord
  belongs_to :track

  validates :label, presence: true
  validates :seconds, presence: true, numericality: { greater_than: 0 }
end
