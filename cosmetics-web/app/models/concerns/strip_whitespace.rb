# Strips whitespaces from attributes before they get validated/saved
#
# Works both with ActiveModel and ActiveRecord classes
# Which attributes will be striped:
# If STRIP_WHITESPACE is defined in the class, only those attributes will be striped.
# If STRIP_WHITESPACE is not defined:
#  - ApplicationRecord classes get all the changed attributes striped (relying on Dirty)
#  - ActiveModel classes get all their attributes striped when possible.
# Example:
# STRIP_WHITESPACE = [:phone, :name]
#
module StripWhitespace
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations::Callbacks unless self.class < ApplicationRecord
    before_validation :strip_whitespace
  end

  def strip_whitespace
    attrs = if self.class.const_defined?("STRIP_WHITESPACE") # Explicit attribute list
              self.class::STRIP_WHITESPACE
            elsif self.class < ApplicationRecord # Every changed attr in ActiveRecord class
              changed
            else # Every attribute in ActiveModel class
              attributes.keys
            end

    attrs.each do |attribute|
      if public_send(attribute).respond_to?(:strip)
        public_send("#{attribute}=", public_send(attribute).strip)
      end
    end
  end
end
