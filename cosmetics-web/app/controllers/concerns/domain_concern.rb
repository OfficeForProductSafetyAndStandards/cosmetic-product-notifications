module DomainConcern
  extend ActiveSupport::Concern

  def search_domain?
    ENV["SEARCH_HOST"].split(',').include?(request.host)
  end

  def submit_domain?
    ENV["SUBMIT_HOST"].split(',').include?(request.host)
  end
end
