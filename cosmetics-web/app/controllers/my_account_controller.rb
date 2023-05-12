require "feature_flags"

class MyAccountController < ApplicationController
  # Sets the ActiveStorage::Current.url_options attribute, which the disk service uses to generate URLs.
  # Include this concern in custom controllers that call ActiveStorage::Blob#url, ActiveStorage::Variant#url,
  # or ActiveStorage::Preview#url so the disk service can generate URLs using the same host, protocol,
  # and port as the current request.
  include ActiveStorage::SetCurrent

  def show; end
end
