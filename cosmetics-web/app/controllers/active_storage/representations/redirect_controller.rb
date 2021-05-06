# frozen_string_literal: true

# Overrides original Rails implementation to disable routes:
# /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format)
# /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)
# We use "rails storage proxy" through ActiveStorage::Blobs::ProxyController
class ActiveStorage::Representations::RedirectController < ActiveStorage::BaseController
  def show
    redirect_to "/"
  end
end
