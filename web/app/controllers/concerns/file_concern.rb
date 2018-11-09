module FileConcern
  extend ActiveSupport::Concern

  def initialize_file_attachment
    session[get_file_session_key] = nil
  end

  def load_file_attachment
    return save_and_store_blob if file_params[:file].present?
    return load_file_by_id if session[get_file_session_key].present?
  end

  def save_and_store_blob
    file = ActiveStorage::Blob.create_after_upload!(
      io: file_params[:file],
      filename: file_params[:file].original_filename,
      content_type: file_params[:file].content_type
    )
    session[get_file_session_key] = file.id
    file.analyze_later
    file
  end

  def load_file_by_id
    ActiveStorage::Blob.find_by(id: session[get_file_session_key])
  end

  def attach_file_to_list(file, attachment_list)
    return unless file

    update_file_details(file)
    attachments = attachment_list.attach(file)
    attachment = attachments.last
    attachment.blob.save
    attachment
  end

  def attach_file_to_attachment_slot(file, attachment_slot)
    return unless file

    update_file_details(file)
    attachment_slot.detach if attachment_slot.attached?
    attachment_slot.attach(file)
    attachment_slot.blob.save
  end

  def update_file_details(file)
    file.metadata.update(file_params)
    file.metadata["updated"] = Time.current
  end

  def validate_blob_size(blob, errors, allowed_size = max_file_byte_size)
    if blob && (blob.byte_size > allowed_size)
      errors.add(:base, :file_too_large, message: "File is too big, allowed size is #{allowed_size / 1.megabyte}MB")
    end
  end

  def get_file_params_key
    # If file upload is part of a bigger form, like correspondence, you need to override this with the key used to get
    # the relevant parameters from params(e.g. :correspondence)
    :file
  end

  def get_file_session_key
    # If for some reason you need to control where in session you store the id of your file, override this
    :file_id
  end

  def max_file_byte_size
    # If you want your controller to allow different max size, override this
    100.megabytes
  end

  def file_params
    return {} if params[get_file_params_key].blank?

    params.require(get_file_params_key).permit(:file, :title, :description, :document_type, :other_type)
  end
end
