class HelperDashboardController < ApplicationController
  layout "app"

  def show
    @active = Current.user.memberships_involving.active.includes(owner: { tracks: :grants })
    @pending = Current.user.memberships_involving.pending
  end
end
