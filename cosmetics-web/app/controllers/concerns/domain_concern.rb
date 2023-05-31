module DomainConcern
  extend ActiveSupport::Concern

  def search_domain?
    search_domains.include?(request.host)
  end

  def submit_domain?
    submit_domains.include?(request.host)
  end

  def support_domain?
    support_domains.include?(request.host)
  end

  def root_path
    if submit_domain?
      submit_root_path
    elsif support_domain?
      support_root_path
    else
      search_root_path
    end
  end

  included do
    helper_method :search_domain?
    helper_method :submit_domain?
    helper_method :support_domain?
    helper_method :root_path
  end

private

  def set_service_name
    @service_name =
      if support_domain?
        "OSU Portal"
      elsif search_domain?
        "Search cosmetic product notifications"
      else
        "Submit cosmetic product notifications"
      end
  end

  def submit_domains
    ENV["SUBMIT_HOST"].split(",")
  end

  def search_domains
    ENV["SEARCH_HOST"].split(",")
  end

  def support_domains
    ENV["SUPPORT_HOST"].split(",")
  end
end
