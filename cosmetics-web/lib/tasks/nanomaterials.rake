require "zip"
require "fileutils"

namespace :nanomaterials do
  desc "Download the Nanomaterial files and compress them into a ZIP file"
  task :download_files, %i[initial_date final_date] => :environment do |_t, args|
    nanos = NanomaterialNotification
    nanos = nanos.where("submitted_at >= '?'", initial_date) if args[:initial_date].present?
    nanos = nanos.where("submitted_at <= '?'", final_date + 1.day) if args[:final_date].present?

    FileUtils.mkdir_p "/tmp/nanomaterial_notifications"
    nanos.find_each do |nano|
      nano.file.open(tmpdir: "/tmp") do |file|
        FileUtils.cp file, "/tmp/nanomaterial_notifications/#{nano.id}.pdf"
      end
    end
  end
end
