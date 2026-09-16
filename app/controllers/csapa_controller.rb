class CsapaController < ApplicationController
  layout "public"

  def index
    @facilities = CsapaFacility.order(:city, :name).limit(100)
    @facilities = @facilities.in_city(params[:q]) if params[:q].present?
  end
end
