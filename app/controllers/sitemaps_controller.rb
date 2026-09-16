class SitemapsController < ApplicationController
  allow_unauthenticated_access

  def show
    @urls = public_paths.filter_map do |path|
      "#{request.base_url}#{path}" if path.present?
    end
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  private

  def public_paths
    [
      root_path,
      auth_path,
      signup_path,
      confidentialite_path,
      mentions_legales_path,
      cgu_path,
      avis_path
    ]
  end
end
