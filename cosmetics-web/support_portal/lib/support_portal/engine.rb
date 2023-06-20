require "active_record_extended"
require "govuk/components"
require "govuk_design_system_formbuilder"

module SupportPortal
  class Engine < ::Rails::Engine
    isolate_namespace SupportPortal

    initializer "support_portal.assets.precompile" do |app|
      app.config.assets.precompile << "support_portal_manifest.js"
    end
  end
end
