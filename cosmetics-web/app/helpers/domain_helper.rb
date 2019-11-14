module DomainHelper
  def submit_domain_url
    root_url(host: submit_host)
  end

  def search_domain_url
    root_url(host: search_host)
  end

private

  def submit_host
    ENV["SUBMIT_HOST"].split(",").first
  end

  def search_host
    ENV["SEARCH_HOST"].split(",").first
  end
end
