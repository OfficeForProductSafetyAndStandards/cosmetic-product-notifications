# requires all dependencies
Gem.loaded_specs['shared-web'].dependencies.each do |d|
  require d.name
end

require "shared/web/engine"

module Shared
  module Web
    # Your code goes here...
  end
end
