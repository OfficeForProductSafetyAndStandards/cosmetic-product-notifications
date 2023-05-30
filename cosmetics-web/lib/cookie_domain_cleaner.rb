class CookieDomainCleaner
  def self.clean(domain)
    domain.gsub(/^\.?(search|submit|support)\./, "")
  end
end
