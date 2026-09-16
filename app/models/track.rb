class Track < ApplicationRecord
  belongs_to :user
  belongs_to :preset, optional: true
  has_many :consumptions, dependent: :destroy
  has_many :milestones, dependent: :destroy
  has_many :share_links, dependent: :destroy
  has_many :grants, dependent: :destroy

  enum :status, { active: 0, paused: 1, closed: 2 }, validate: true

  validates :name, presence: true, length: { maximum: 60 }
  validates :quit_at, presence: true
  validates :color, presence: true

  scope :ordered, -> { order(:created_at) }
  scope :for_user, ->(user) { where(user:) }

  after_create :build_milestones_from_preset

  def elapsed_seconds
    return (paused_seconds || 0) if paused?

    now = closed? ? (closed_at || Time.current) : Time.current
    return 0 unless quit_at

    [ (now - quit_at).to_i, 0 ].max
  end

  def elapsed_days
    elapsed_seconds / 86_400
  end

  def next_milestone
    milestones.where(reached_at: nil).order(:seconds).first
  end

  def check_milestones!
    reach_due_milestones
  end

  def check_milestones_with_notification!
    reached = milestones.where(reached_at: nil)
                        .where(Milestone.arel_table[:seconds].lteq(elapsed_seconds))
                        .to_a
    reach_due_milestones
    reached.select(&:reload)
           .select(&:reached_at?)
  end

  def reach_due_milestones
    return if paused? || closed?

    elapsed = elapsed_seconds
    milestones.where(reached_at: nil)
              .where(Milestone.arel_table[:seconds].lteq(elapsed))
              .find_each do |milestone|
      milestone.update!(reached_at: quit_at + milestone.seconds)
    end
  end

  def restart!
    update_personal_best!
    update!(quit_at: Time.current, status: :active, paused_seconds: nil, closed_at: nil)
  end

  def pause!
    update!(paused_seconds: elapsed_seconds, status: :paused)
  end

  def resume!
    update!(quit_at: Time.current - (paused_seconds || 0), paused_seconds: nil, status: :active)
  end

  def close!
    update_personal_best!
    update!(closed_at: Time.current, status: :closed)
  end

  def update_personal_best!
    best = [ personal_best_seconds, elapsed_seconds ].max
    update!(personal_best_seconds: best) if best > personal_best_seconds
  end

  def status_human
    I18n.t("tracks.#{status}_badge")
  end

  def consumption_days
    @consumption_days ||= consumptions.pluck(:occurred_at).map { |d| d.in_time_zone.to_date }.tally
  end

  def consumption_days_in(month)
    consumptions.where(occurred_at: month.beginning_of_day..month.end_of_month.end_of_day)
                .pluck(:occurred_at).map { |d| d.in_time_zone.to_date }.tally
  end

  private

  def build_milestones_from_preset
    definitions = preset&.milestones.presence || Preset::CATALOGUE.first[:milestones]
    definitions.each do |definition|
      milestones.create!(label: definition["label"] || definition[:label], seconds: definition["seconds"] || definition[:seconds])
    end
  end
end
