class UploadCosmeticProductsContainingNanomaterialsJob < ApplicationJob
  SQL_QUERY = <<~SQL.freeze
    SELECT responsible_persons.name as "Responsible Person",
           product_name as "Cosmetic product name",
           DATE(notification_complete_at) as "Date cosmetic product was notified",
           reference_number as "UKCP number",
           inci_name as "INCI name",
           purposes as "Nanomaterial purposes"
    FROM nano_elements
    INNER JOIN nano_materials
      ON nano_elements.nano_material_id = nano_materials.id
    INNER JOIN notifications
      ON nano_materials.notification_id = notifications.id
    INNER JOIN responsible_persons
      ON notifications.responsible_person_id = responsible_persons.id
    WHERE notification_complete_at IS NOT NULL
    ORDER BY notification_complete_at ASC
  SQL

  FILE_NAME = "CosmeticsProductsContainingNanomaterials.csv".freeze
  FILE_PATH = Rails.root.join("tmp/#{FILE_NAME}").freeze

  def perform
    generate_csv_file
    upload_to_cloud_storage
    delete_tmp_file
    delete_previous_uploads
  end

private

  def generate_csv_file
    conn = ActiveRecord::Base.connection.raw_connection

    File.open(FILE_PATH, "w") do |f|
      conn.copy_data "COPY (#{SQL_QUERY}) TO STDOUT WITH CSV HEADER;" do
        while (line = conn.get_copy_data)
          f.write line.force_encoding("UTF-8")
        end
      end
    end
  end

  def upload_to_cloud_storage
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(FILE_PATH),
      filename: FILE_NAME,
    )
  end

  def delete_tmp_file
    File.delete(FILE_PATH) if File.exist?(FILE_PATH)
  end

  def delete_previous_uploads
    uploads = ActiveStorage::Blob.where(filename: FILE_NAME).order(created_at: :desc)
    uploads.drop(1).each(&:purge) # Purges all but the 1st (latest created) one.
  end
end
