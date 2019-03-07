# requires all dependencies
Gem.loaded_specs['shared-web'].dependencies.each do |d|
  require d.name unless d.name.include? "elasticsearch"
end

# Elasticsearch gems need to be 'required' with a different name than gem name, hence we do it separately
require "elasticsearch/model"
require "elasticsearch/rails"

require "shared/web/engine"

module Shared
  module Web
    # Your code goes here...
  end
end
