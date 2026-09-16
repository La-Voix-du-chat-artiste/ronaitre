module Csapa
  class RefreshJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info("[csapa] refresh placeholder — la production branchera l'annuaire public Drogues Info Service ici")
    end
  end
end
