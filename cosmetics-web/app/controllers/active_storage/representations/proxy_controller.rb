# frozen_string_literal: true

# Overrides original Rails implementation to disable route:
# /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)
# We use "rails storage proxy" through ActiveStorage::Blobs::ProxyController
class ActiveStorage::Representations::ProxyController < ActiveStorage::BaseController
  def show
    redirect_to "/"
  end
end
