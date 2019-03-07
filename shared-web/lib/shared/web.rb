# requires all dependencies
Gem.loaded_specs['shared-web'].dependencies.each do |d|
  require d.name unless d.name.include? "elasticsearch"
end

require "elasticsearch/model"
require "elasticsearch/rails"

require "shared/web/engine"

module Shared
  module Web
    # Your code goes here...
  end
end
