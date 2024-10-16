class PostgresCsvUploadJob < ActiveStorageUploadJob
  # Abstract methods.
  # Need to be defined in subclasses.
  def self.sql_query
    raise NotImplementedError, "Subclasses must define `sql_query`."
  end

  def self.file_name
    self::FILE_NAME # FILE_NAME constant needs to be defined in subclasses.
  end

private

  def generate_local_file
    conn = ActiveRecord::Base.connection.raw_connection

    File.open(self.class.file_path, "w") do |f|
      conn.copy_data "COPY (#{self.class.sql_query}) TO STDOUT WITH CSV HEADER;" do
        while (line = conn.get_copy_data)
          f.write line.force_encoding("UTF-8")
        end
      end
    end
  end
end
