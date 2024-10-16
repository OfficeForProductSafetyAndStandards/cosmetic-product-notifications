module DomainHelper
  def submit_domain_url
    root_url(host: ENV["SUBMIT_HOST"])
  end

  def search_domain_url
    root_url(host: ENV["SEARCH_HOST"])
  end

  def support_domain_url
    root_url(host: ENV["SUPPORT_HOST"])
  end
end
