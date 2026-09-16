class LegalController < ApplicationController
  layout "public"
  allow_unauthenticated_access

  def privacy
  end

  def legal_notice
  end

  def terms
  end
end
