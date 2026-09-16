class CsapaFacility < ApplicationRecord
  validates :name, presence: true

  scope :in_city, ->(query) { where("city ILIKE :q OR dept ILIKE :q OR name ILIKE :q", q: "%#{query}%") }
end
