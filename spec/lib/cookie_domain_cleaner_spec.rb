require "rails_helper"
require "cookie_domain_cleaner"

RSpec.describe CookieDomainCleaner do
  [
    ["submit.cosmetic-product-notifications.service.gov.uk", "cosmetic-product-notifications.service.gov.uk"],
    ["search.cosmetic-product-notifications.service.gov.uk", "cosmetic-product-notifications.service.gov.uk"],
    [".submit.cosmetic-product-notifications.service.gov.uk", "cosmetic-product-notifications.service.gov.uk"],
    [".search.cosmetic-product-notifications.service.gov.uk", "cosmetic-product-notifications.service.gov.uk"],
    ["cosmetics-pr-2497-submit-web.london.cloudapps.digital", "cosmetics-pr-2497-submit-web.london.cloudapps.digital"],
  ].each do |domain, target_domain|
    it "cleanups properly" do
      expect(described_class.clean(domain)).to eq(target_domain)
    end
  end
end
