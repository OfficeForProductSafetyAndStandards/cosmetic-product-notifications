module Clonable
  extend ActiveSupport::Concern

  included do
    attribute :cloned_from
  end
end
