class PagesController < ApplicationController
  layout "public"
  allow_unauthenticated_access

  def home
  end
end
