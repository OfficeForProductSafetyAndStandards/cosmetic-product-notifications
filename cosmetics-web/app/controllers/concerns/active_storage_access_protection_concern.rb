module ActiveStorageAccessProtectionConcern
  extend ActiveSupport::Concern
  include Pundit
  include DomainConcern

  def pundit_user
    current_submit_user
  end

  # Checks that:
  # - The current user is a signed in user.
  # - If Submit user, has view permissions for the Responsible Person associated to the file.
  # Notice:
  # Record class must implement (or have a delegation to) "#responsible_person"
  # to be able to use this concern.
  def authorize_blob
    if submit_domain?
      raise Pundit::NotAuthorizedError unless submit_user_signed_in?

      rp = @blob.attachments.first.record.responsible_person
      authorize rp, :show?
    else
      raise Pundit::NotAuthorizedError unless search_user_signed_in?
    end
  end
end
