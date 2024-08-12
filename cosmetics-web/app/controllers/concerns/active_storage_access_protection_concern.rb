module ActiveStorageAccessProtectionConcern
  extend ActiveSupport::Concern
  include Pundit::Authorization
  include DomainConcern

  def pundit_user
    current_submit_user
  end

  def authorize_blob
    if submit_domain?
      raise Pundit::NotAuthorizedError unless submit_user_signed_in?

      rp = @blob.attachments.first.record.responsible_person

      authorize rp, :show?
    else
      raise Pundit::NotAuthorizedError unless search_user_signed_in? || support_user_signed_in?
    end
  end
end
