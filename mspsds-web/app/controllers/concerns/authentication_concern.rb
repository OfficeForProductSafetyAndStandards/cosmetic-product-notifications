module AuthenticationConcern
  extend ActiveSupport::Concern
  include Shared::Web::Concerns::AuthenticationConcern
  def no_need_to_authenticate
    public_addresses.each do |address|
      return true if request.original_fullpath.include? address
    end
  end

  def public_addresses
    %w[terms_and_conditions about privacy_policy]
  end
end
