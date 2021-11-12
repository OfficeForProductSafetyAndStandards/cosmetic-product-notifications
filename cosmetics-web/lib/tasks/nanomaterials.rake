require "zip"
require "fileutils"

namespace :nanomaterials do
  desc "Download the Nanomaterial files and compress them into a ZIP file"
  task :download_files, %i[initial_date final_date] => :environment do |_t, args|
    nanos = NanomaterialNotification
    nanos = nanos.where("submitted_at >= '?'", initial_date) if args[:initial_date].present?
    nanos = nanos.where("submitted_at <= '?'", final_date + 1.day) if args[:final_date].present?

    zip_file = "/tmp/nanomaterial_notifications.zip"

    ::Zip::File.open(zip_file, create: true) do |zipfile|
      nanos.find_each do |nano|
        nano.file.open(tmpdir: "/tmp") do |file|
          zipfile.add("#{nano.id}.pdf", file)
        end
      end
    end
  end
end
