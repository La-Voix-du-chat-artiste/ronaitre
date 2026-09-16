class Preset < ApplicationRecord
  has_many :tracks, dependent: :nullify

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }

  def self.seed!
    CATALOGUE.each do |attributes|
      Preset.find_or_create_by!(slug: attributes[:slug]) do |preset|
        preset.assign_attributes(attributes)
      end
    end
  end

  CATALOGUE = [
    {
      slug: "tabac",
      name: "Tabac",
      icon: "cigarette",
      color: "salmon",
      unit_word: "cigarettes",
      guide_slug: "arreter-de-fumer",
      milestones: [
        { label: "24 h", seconds: 86_400 },
        { label: "7 jours", seconds: 604_800 },
        { label: "1 mois", seconds: 2_592_000 },
        { label: "3 mois", seconds: 7_776_000 },
        { label: "6 mois", seconds: 15_552_000 },
        { label: "1 an", seconds: 31_536_000 }
      ]
    },
    {
      slug: "alcool",
      name: "Alcool",
      icon: "wine",
      color: "periwinkle",
      unit_word: "verres",
      guide_slug: "sevrage-alcool",
      milestones: [
        { label: "24 h", seconds: 86_400 },
        { label: "3 jours", seconds: 259_200 },
        { label: "7 jours", seconds: 604_800 },
        { label: "1 mois", seconds: 2_592_000 },
        { label: "3 mois", seconds: 7_776_000 },
        { label: "1 an", seconds: 31_536_000 }
      ]
    },
    {
      slug: "cannabis",
      name: "Cannabis",
      icon: "leaf",
      color: "mint",
      unit_word: "joints",
      milestones: [
        { label: "24 h", seconds: 86_400 },
        { label: "7 jours", seconds: 604_800 },
        { label: "1 mois", seconds: 2_592_000 },
        { label: "3 mois", seconds: 7_776_000 },
        { label: "1 an", seconds: 31_536_000 }
      ]
    },
    {
      slug: "jeux",
      name: "Jeux d'argent",
      icon: "dice",
      color: "chart-1",
      unit_word: "sessions",
      milestones: [
        { label: "24 h", seconds: 86_400 },
        { label: "7 jours", seconds: 604_800 },
        { label: "1 mois", seconds: 2_592_000 },
        { label: "3 mois", seconds: 7_776_000 },
        { label: "1 an", seconds: 31_536_000 }
      ]
    },
    {
      slug: "ecrans",
      name: "Écrans",
      icon: "monitor-smartphone",
      color: "chart-3",
      unit_word: "heures",
      milestones: [
        { label: "24 h", seconds: 86_400 },
        { label: "3 jours", seconds: 259_200 },
        { label: "7 jours", seconds: 604_800 },
        { label: "1 mois", seconds: 2_592_000 },
        { label: "3 mois", seconds: 7_776_000 }
      ]
    }
  ].freeze
end
