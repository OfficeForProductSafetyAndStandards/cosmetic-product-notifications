class CookieDomainCleaner
  def self.clean(domain)
    domain.gsub(/^\.?(search|submit)\./, "")
  end
end
