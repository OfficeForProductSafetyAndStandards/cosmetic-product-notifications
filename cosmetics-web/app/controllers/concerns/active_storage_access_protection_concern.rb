module ActiveStorageAccessProtectionConcern
  extend ActiveSupport::Concern
  include Pundit::Authorization
  include DomainConcern

  def pundit_user
    current_submit_user
  end

  def authorize_blob
    if submit_domain?
      unless submit_user_signed_in?
        flash[:alert] = "You must be signed in to access this resource."
        redirect_to submit_root_path and return
      end

      rp = @blob.attachments.first.record.responsible_person
      begin
        authorize rp, :show?
      rescue Pundit::NotAuthorizedError
        flash[:alert] = "You do not have permission to access this resource."
        redirect_to submit_root_path and return
      end
    elsif search_user_signed_in?
      unless current_search_user && allow_access_search_user
        flash[:alert] = "You do not have permission to access this resource."
        redirect_to poison_centre_notifications_search_path and return
      end
    elsif support_user_signed_in?
      unless current_support_user && allow_access_support_user
        flash[:alert] = "You do not have permission to access this resource."
        redirect_to support_portal.support_root_path and return
      end
    else
      flash[:alert] = "You must be signed in to access this resource."
      redirect_to search_root_path and return
    end

    # Serve the blob data directly using send_data
    send_data @blob.download, filename: @blob.filename.to_s, type: @blob.content_type, disposition: "inline"
  end

  def allow_access_search_user
    return false unless current_search_user&.role

    if current_search_user.has_role?(:opss_general)
      return  @blob.attachments.first&.record_type == "ImageUpload"
    end

    true
  end

  def allow_access_support_user
    return false unless current_support_user&.role

    if current_support_user.has_role?(:opss_general)
      return  @blob.attachments.first&.record_type == "ImageUpload"
    end

    true
  end
end
