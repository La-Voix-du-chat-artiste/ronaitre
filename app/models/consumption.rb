class Consumption < ApplicationRecord
  belongs_to :track

  validates :occurred_at, presence: true
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true
  validates :note, length: { maximum: 500 }
end
