class AddCreatedByToFileBlob < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do

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
