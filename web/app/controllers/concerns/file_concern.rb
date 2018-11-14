module FileConcern
  extend ActiveSupport::Concern

  def initialize_file_attachment attachment_category
    session[attachment_category] = nil
  end

  def load_file_attachment attachment_category
    return save_and_store_blob attachment_category if file_params(attachment_category)[attachment_category].present?
    return load_file_by_id attachment_category if session[attachment_category].present?
  end

  def save_and_store_blob attachment_category
    evaluated_file_params = file_params(attachment_category)[attachment_category]
    file = ActiveStorage::Blob.create_after_upload!(
      io: evaluated_file_params,
      filename: evaluated_file_params.original_filename,
      content_type: evaluated_file_params.content_type
    )
    session[attachment_category] = file.id
    file.analyze_later
    file
  end

  def load_file_by_id attachment_category
    ActiveStorage::Blob.find_by(id: session[attachment_category])
  end

  # has_many
  def attach_file_to_list(file, attachment_category, attachment_list)
    return unless file

    update_file_details(file, attachment_category)
    attachments = attachment_list.attach(file)
    attachment = attachments.last
    attachment.blob.save
    attachment
  end

  def attach_file_to_attachment_slot(file, attachment_slot)
    return unless file

    update_file_details(file, attachment_category)
    attachment_slot.detach if attachment_slot.attached?
    attachment_slot.attach(file)
    attachment_slot.blob.save
  end

  def update_file_details(file, attachment_category)
    file_metadata = file_params(attachment_category).merge(attachment_category: attachment_category)
    file.metadata.update(file_metadata)
    file.metadata["updated"] = Time.current
  end

  def validate_blob_size(blob, errors, attachment_category, allowed_size = max_file_byte_size)
    if blob && (blob.byte_size > allowed_size)
      errors.add(:base, :file_too_large, message: "#{attachment_category} is too big, allowed size is #{allowed_size / 1.megabyte}MB")
    end
  end

  def get_file_params_key
    # If file upload is part of a bigger form, like correspondence, you need to override this with the key used to get
    # the relevant parameters from params(e.g. :correspondence)
    :file
  end

  def get_file_session_key
    # If for some reason you need to control where in session you store the id of your file, override this
    :file
  end

  def max_file_byte_size
    # If you want your controller to allow different max size, override this
    100.megabytes
  end

  def file_params attachment_category
    return {} if params[get_file_params_key].blank?

    params.require(get_file_params_key).permit(:file, attachment_category, :title, :description, :document_type, :other_type)
  end
end
