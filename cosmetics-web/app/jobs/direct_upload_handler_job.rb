class DirectUploadHandlerJob < ApplicationJob
  def perform(uploaded_files, uploaded_file_names, responsible_person_id, current_user_id)
    DirectUploadHandler.new(uploaded_files, uploaded_file_names, responsible_person_id, current_user_id).call
  end
end
