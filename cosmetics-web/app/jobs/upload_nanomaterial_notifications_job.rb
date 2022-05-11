class UploadNanomaterialNotificationsJob < ActiveStorageUploadJob
  SQL_QUERY = <<~SQL.freeze
    SELECT rp.name as "Responsible Person",
           cp.email_address as "Contact person email address",
           nano.id as "UKN number",
           DATE(nano.submitted_at) as "Date nanomaterial notification was submitted",
           nano.name as "Name of the nanomaterial",
           CAST(nano.eu_notified as TEXT) as "Was the EU notified about test on CPNP before 1 January 2021?",
           nano.notified_to_eu_on as "Date EU notified on"
    FROM nanomaterial_notifications as nano
    INNER JOIN responsible_persons as rp
      ON rp.id = nano.responsible_person_id
    INNER JOIN contact_persons as cp
      ON rp.id = cp.responsible_person_id
    WHERE nano.submitted_at IS NOT NULL
    ORDER BY nano.submitted_at ASC
  SQL

  FILE_NAME = "NanomaterialNotifications.csv".freeze

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
