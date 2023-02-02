class UploadCosmeticProductsInLastThreeMonthsContainingNanomaterialsJob < PostgresCsvUploadJob
  FILE_NAME = "CosmeticsProductsInLastThreeMonthsContainingNanomaterials.csv".freeze

  def self.sql_query
    <<~SQL
      SELECT responsible_persons.name as "Responsible Person",
            product_name as "Cosmetic product name",
            DATE(notification_complete_at) as "Date cosmetic product was notified",
            reference_number as "UKCP number",
            inci_name as "INCI name",
            purposes as "Nanomaterial purposes",
            nano_materials.nanomaterial_notification_id as "UKN number"
      FROM nano_materials
      INNER JOIN notifications
        ON nano_materials.notification_id = notifications.id
      INNER JOIN responsible_persons
        ON notifications.responsible_person_id = responsible_persons.id
      WHERE (notification_complete_at > '#{3.months.ago.beginning_of_month.to_date}')
      ORDER BY notification_complete_at ASC
    SQL
  end
end
