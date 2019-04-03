class AddCreatedByToFileBlob < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        ActiveStorage::Blob.all.each do |blob|
          metadata = blob.metadata
          first_activity = blob.attachments.where(record_type: "Activity").order(:created_at).first.record
          blob.metadata.update(metadata.merge(created_by: first_activity&.source&.user_id))
          blob.save
        end
      end

      dir.down do
        ActiveStorage::Blob.all.each do |blob|
          metadata = blob.metadata
          metadata.delete :created_by
          blob.metadata.update(metadata)
          blob.save
        end
      end
    end
  end
end
