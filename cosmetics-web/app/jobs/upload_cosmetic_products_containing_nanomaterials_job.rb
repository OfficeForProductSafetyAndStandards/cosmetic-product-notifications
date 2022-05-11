class UploadCosmeticProductsContainingNanomaterialsJob < ActiveStorageUploadJob
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

  def self.file_name
    self::FILE_NAME
  end

private

  def generate_local_file
    conn = ActiveRecord::Base.connection.raw_connection

    File.open(self.class.file_path, "w") do |f|
      conn.copy_data "COPY (#{SQL_QUERY}) TO STDOUT WITH CSV HEADER;" do
        while (line = conn.get_copy_data)
          f.write line.force_encoding("UTF-8")
        end
      end
    end
  end
end
