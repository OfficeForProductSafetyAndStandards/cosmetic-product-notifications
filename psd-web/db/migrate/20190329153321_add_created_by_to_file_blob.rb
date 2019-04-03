class AddCreatedByToFileBlob < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        ActiveStorage::Blob.all.each do |blob|
          metadata = blob.metadata
          activity = blob.attachments.where(record_type:"Activity").order(:created_at).first
          investigation = blob.attachments.where(record_type: "Investigation").order(:created_at).first
          original_source = (activity || investigation)&.record&.source
          if original_source.present? && (original_source.is_a? UserSource)
            blob.metadata.update(metadata.merge(created_by: original_source.user_id))
            blob.save
          end
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
