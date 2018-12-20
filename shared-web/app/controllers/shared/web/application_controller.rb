module Shared
  module Web
    class ApplicationController < ActionController::Base
      include Shared::Web::Concerns::ApplicationConcern
    end
  end
end
