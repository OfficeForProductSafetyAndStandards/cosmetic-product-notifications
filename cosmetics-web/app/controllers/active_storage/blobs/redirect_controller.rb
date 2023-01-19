# frozen_string_literal: true

# Take a signed permanent reference for a blob and turn it into an expiring service URL for download.
#
# WARNING: All Active Storage controllers are publicly accessible by default. The
# generated URLs are hard to guess, but permanent by design. If your files
# require a higher level of protection consider implementing
# {Authenticated Controllers}[https://guides.rubyonrails.org/active_storage_overview.html#authenticated-controllers].
class ActiveStorage::Blobs::RedirectController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob

  # Cosmetics note:
  # Overrides original Rails implementation to disable routes:
  # /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)
  # /rails/active_storage/blobs/:signed_id/*filename(.:format)
  # We use "rails storage proxy" through ActiveStorage::Blobs::ProxyController
  def show
    redirect_to "/"
  end
end
