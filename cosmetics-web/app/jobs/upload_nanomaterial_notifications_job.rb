class UploadNanomaterialNotificationsJob < ApplicationJob
  SQL_QUERY = <<~SQL.freeze
    SELECT rp.name as "Responsible Person",
           cp.email_address as "Contact person email address",
           nano.id as "UKN number",
           DATE(nano.submitted_at) as "Date nanomaterial notification was submitted",
           nano.name as "Name of the nanomaterial",
           nano.eu_notified as "Was the EU notified about test on CPNP before 1 January 2021?",
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
