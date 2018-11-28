module Shared
  module Web
    class Engine < ::Rails::Engine
      isolate_namespace Shared::Web
    end
  end
end
