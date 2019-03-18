module AuthenticationConcern
  extend ActiveSupport::Concern
  include Shared::Web::Concerns::AuthenticationConcern
  def no_need_to_authenticate
    public_addresses.each do |address|
      return true if request.original_fullpath.include? address
    end

    false
  end

  def public_addresses
    %w[terms-and-conditions about privacy-policy]
  end
end
