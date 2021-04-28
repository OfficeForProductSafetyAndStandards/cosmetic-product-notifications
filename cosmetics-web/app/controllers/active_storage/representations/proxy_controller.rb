# frozen_string_literal: true

# Proxy files through application. This avoids having a redirect and makes files easier to cache.
# This is override from original rails implementation
class ActiveStorage::Representations::ProxyController < ActiveStorage::BaseController
  def show
    redirect_to "/"
  end
end
