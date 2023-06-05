module DomainConcern
  extend ActiveSupport::Concern

  def search_domain?
    search_domain == request.host
  end

  def submit_domain?
    submit_domain == request.host
  end

  def support_domain?
    support_domain == request.host
  end

  def root_path
    if submit_domain?
      submit_root_path
    elsif support_domain?
      support_portal.support_root_path
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
    @service_name = if submit_domain?
                      "Submit cosmetic product notifications"
                    elsif support_domain?
                      "OSU Support Portal"
                    else
                      "Search cosmetic product notifications"
                    end
  end

  def submit_domain
    ENV["SUBMIT_HOST"]
  end

  def search_domain
    ENV["SEARCH_HOST"]
  end

  def support_domain
    ENV["SUPPORT_HOST"]
  end
end
