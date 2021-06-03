# frozen_string_literal: true

# Proxy files through application. This avoids having a redirect and makes files easier to cache.
# Overrides Rails Controller to enforce access protection beyond the security-through-obscurity
# factor of the signed blob and variation reference.
# Only owners and search users have access to files.
class ActiveStorage::Blobs::ProxyController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include ActiveStorage::SetHeaders
  include ActiveStorageAccessProtectionConcern

  before_action :authorize_blob

  def show
    http_cache_forever public: true do
      set_content_headers_from @blob
      stream @blob
    end
  end
end
