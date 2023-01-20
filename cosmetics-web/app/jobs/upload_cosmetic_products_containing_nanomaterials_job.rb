class UploadCosmeticProductsContainingNanomaterialsJob < PostgresCsvUploadJob
  SQL_QUERY = <<~SQL.freeze
    SELECT responsible_persons.name as "Responsible Person",
           product_name as "Cosmetic product name",
           DATE(notification_complete_at) as "Date cosmetic product was notified",
           reference_number as "UKCP number",
           inci_name as "INCI name",
           purposes as "Nanomaterial purposes"
    FROM nano_materials
    INNER JOIN notifications
      ON nano_materials.notification_id = notifications.id
    INNER JOIN responsible_persons
      ON notifications.responsible_person_id = responsible_persons.id
    WHERE notification_complete_at IS NOT NULL
    ORDER BY notification_complete_at ASC
  SQL

  FILE_NAME = "CosmeticsProductsContainingNanomaterials.csv".freeze

  def self.sql_query
    self::SQL_QUERY
  end
end
