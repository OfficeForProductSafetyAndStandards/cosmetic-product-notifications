require "zip"
require "fileutils"

namespace :nanomaterials do
  desc "Download the Nanomaterial files and compress them into a ZIP file"
  task :download_files, %i[initial_date final_date] => :environment do |_t, args|
    nanos = NanomaterialNotification
    nanos = nanos.where("submitted_at >= '?'", initial_date) if args[:initial_date].present?
    nanos = nanos.where("submitted_at <= '?'", final_date + 1.day) if args[:final_date].present?

    zip_file = "/tmp/nanomaterial_notifications.zip"
    tmpdir = "/tmp/nanomaterial_notifications"

    FileUtils.mkdir_p(tmpdir)
    nanos.find_each do |nano|
      nano.file.open(tmpdir: "/tmp") do |file|
        FileUtils.cp(file, "#{tmpdir}/#{nano.id}.pdf")
      end
    end

    zip_entries = Dir.entries(tmpdir) - %w[. ..]
    ::Zip::File.open(zip_file, create: true) do |zipfile|
      zip_entries.each do |entry|
        zipfile.add(File.basename(entry), entry)
      end
    end

    FileUtils.remove_dir(tmpdir)
  end
end
