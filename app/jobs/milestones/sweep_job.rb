module Milestones
  class SweepJob < ApplicationJob
    queue_as :default

    def perform
      Track.active.find_each do |track|
        newly_reached = track.check_milestones_with_notification!
        next if newly_reached.empty?

        Rails.logger.info("[milestones] track##{track.id} reached: #{newly_reached.map(&:label).join(', ')}")
      end
    end
  end
end
