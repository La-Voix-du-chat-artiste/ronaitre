class SitemapsController < ApplicationController
  allow_unauthenticated_access

  def show
    @entries = indexable_paths.map do |path, priority|
      { loc: "#{request.base_url}#{path}", priority: priority }
    end
    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  private

  def indexable_paths
    {
      root_path => "1.0",
      aidants_path => "0.8",
      csapa_path => "0.8",
      confidentialite_path => "0.3",
      mentions_legales_path => "0.3",
      cgu_path => "0.3"
    }
  end
end
