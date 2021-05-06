# frozen_string_literal: true

# Overrides original Rails implementation to disable routes:
# /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)
# /rails/active_storage/blobs/:signed_id/*filename(.:format)
# We use "rails storage proxy" through ActiveStorage::Blobs::ProxyController
class ActiveStorage::Blobs::RedirectController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob

  def show
    redirect_to "/"
  end
end
