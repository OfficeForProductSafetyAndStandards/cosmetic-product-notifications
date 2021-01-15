class DirectUploadHandler
  def initialize(signed_ids, uploaded_file_names, responsible_person_id, submit_user_id)
    @signed_ids = signed_ids
    @uploaded_file_names = uploaded_file_names.map { |f| File.basename(f, ".*") }
    @responsible_person = ResponsiblePerson.find(responsible_person_id)
    @submit_user = SubmitUser.find(submit_user_id)
  end

  def call
    notification_file_ids = []
    @present_names = []
    @signed_ids.each do |id|
      begin
        uploaded_file = ActiveStorage::Blob.find_signed id
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        next
      end

      name = uploaded_file.filename.base
      notification_file = NotificationFile.new(
        name: name,
        responsible_person: @responsible_person,
        user: @submit_user,
      )
      notification_file.uploaded_file.attach(uploaded_file)
      notification_file.save!
      @present_names << name

      notification_file_ids << notification_file.id
    end

    handle_missing_files
  end

  def handle_missing_files
    (@uploaded_file_names - @present_names).each do |name|
      NotificationFile.new(
        name: name,
        responsible_person: @responsible_person,
        user: @submit_user,
        upload_error: :file_upload_failed,
      ).save(validate: false)
    end
  end
end
