class AidantsController < ApplicationController
  layout "public"

  def index
    @aidants = User.where(role: "aidant").order(:created_at).limit(50)
  end
end
