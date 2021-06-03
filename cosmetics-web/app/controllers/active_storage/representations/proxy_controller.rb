# frozen_string_literal: true

# Proxy files through application. This avoids having a redirect and makes files easier to cache.
# Overrides Rails Controller to enforce access protection beyond the security-through-obscurity
# factor of the signed blob and variation reference.
# Only owners and search users have access to files.
#
# This route is used for images thumbnails
# /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)
class ActiveStorage::Representations::ProxyController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include ActiveStorage::SetHeaders
  include ActiveStorageAccessProtectionConcern

  before_action :authorize_blob

  def show
    http_cache_forever public: true do
      set_content_headers_from representation.image
      stream representation
    end
  end

private

  def representation
    @representation ||= @blob.representation(params[:variation_key]).processed
  end
end
