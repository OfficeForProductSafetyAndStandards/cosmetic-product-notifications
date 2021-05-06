module DomainConcern
  extend ActiveSupport::Concern

  def search_domain?
    search_domains.include?(request.host)
  end

  def submit_domain?
    submit_domains.include?(request.host)
  end

  def root_path
    submit_domain? ? submit_root_path : search_root_path
  end

  included do
    helper_method :search_domain?
    helper_method :submit_domain?
    helper_method :root_path
  end

private

  def set_service_name
    @service_name = search_domain? ? "Search cosmetic product notifications" : "Submit cosmetic product notifications"
  end

  def submit_domains
    ENV["SUBMIT_HOST"].split(",")
  end

  def search_domains
    ENV["SEARCH_HOST"].split(",")
  end
end
