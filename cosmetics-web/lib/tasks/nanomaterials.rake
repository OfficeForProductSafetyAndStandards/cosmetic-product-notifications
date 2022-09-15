require "zip"
require "fileutils"

namespace :nanomaterials do
  desc "Download the Nanomaterial files and compress them into a ZIP file"
  task :download_files, %i[initial_date final_date] => :environment do |_t, args|
    nanos = NanomaterialNotification
    nanos = nanos.where("submitted_at >= ?", args[:initial_date]) if args[:initial_date].present?
    nanos = nanos.where("submitted_at <= ?", Time.zone.parse(args[:final_date]) + 1.day) if args[:final_date].present?

    zip_file = "tmp/nanomaterial_notifications.zip"
    tmpdir = "tmp/nanomaterial_notifications"

    FileUtils.mkdir_p(tmpdir)
    nanos.find_each do |nano|
      nano.file.open(tmpdir: "tmp") do |file|
        FileUtils.cp(file, "#{tmpdir}/#{nano.id}.pdf")
      end
    end

    input_filenames = Dir.children(tmpdir)
    ::Zip::File.open(zip_file, create: true) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(File.basename(filename), "#{tmpdir}/#{filename}")
      end
    end
    FileUtils.remove_dir(tmpdir)

    puts "Zip generated at '~/app/#{zip_file}'"
    puts "To download the file, execute in YOUR COMPUTER shell:"
    puts "cf ssh APPNAME -c 'cat ~/app/tmp/nanomaterial_notifications.zip' > nanomaterial_notifications.zip"
  end

  # TODO: Remove this task once the NanoMaterial and NanoElement models are merged.
  desc "Delete nanomaterials without associated nanoelements"
  task delete_nanomaterials_without_nanoelements: :environment do
    nanomaterials_without_nanoelements = NanoMaterial.left_joins(:nano_elements).where(nano_elements: { id: nil })
    affected_count = nanomaterials_without_nanoelements.count
    puts "Found #{affected_count} nanomaterials without any associated nanoelement"
    puts "Deleting them..."
    nanomaterials_without_nanoelements.delete_all # Dont delete associated objects
    puts "#{affected_count} nanomaterials without nanoelements deleted"
  end

  # TODO: Remove this task once the NanoMaterial and NanoElement models are merged.
  desc "Delete NanoMaterial and their nanoelements without any associated component or notification"
  task delete_orphan_nanomaterials: :environment do
    orphan_nanomaterials = NanoMaterial.left_joins(:component_nano_materials)
                                       .where(component_nano_materials: { nano_material_id: nil },
                                              nano_materials: { component_id: nil, notification_id: nil })
    affected_count = orphan_nanomaterials.count
    puts "Found #{affected_count} orphan nanomaterials without any associated components or notifications"
    puts "Deleting them..."
    orphan_nanomaterials.destroy_all # Also destroy associated Nano Elements.
    puts "#{affected_count} orphan nanomaterials deleted"
  end
end
