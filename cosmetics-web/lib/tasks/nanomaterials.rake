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
    task_name = "[nanomaterials:delete_nanomaterials_without_nanoelements]"
    nanomaterials_without_nanoelements = NanoMaterial.left_joins(:nano_elements).where(nano_elements: { id: nil })
    affected_count = nanomaterials_without_nanoelements.count
    Rails.logger.info "#{task_name} Found #{affected_count} nanomaterials without any associated nanoelement"
    Rails.logger.info "#{task_name} Deleting them..."
    nanomaterials_without_nanoelements.delete_all # Dont delete associated objects
    Rails.logger.info "#{task_name} #{affected_count} nanomaterials without nanoelements deleted"
  end

  # TODO: Remove this task once the NanoMaterial and NanoElement models are merged.
  desc "Delete NanoMaterial and their nanoelements without any associated component or notification"
  task delete_orphan_nanomaterials: :environment do
    task_name = "[nanomaterials:delete_orphan_nanomaterials]"
    orphan_nanomaterials = NanoMaterial.left_joins(:component_nano_materials)
                                       .where(component_nano_materials: { nano_material_id: nil },
                                              nano_materials: { notification_id: nil })
    affected_count = orphan_nanomaterials.count
    Rails.logger.info "#{task_name} Found #{affected_count} orphan nanomaterials without any associated components or notifications"
    Rails.logger.info "#{task_name} Deleting them..."
    orphan_nanomaterials.destroy_all # Also destroy associated Nano Elements.
    Rails.logger.info "#{task_name} #{affected_count} orphan nanomaterials deleted"
  end

  desc "Associate nanoelements with unique nanomaterials"
  task single_nanoelement_per_nanomaterial: :environment do
    task_name = "[nanomaterials:single_nanoelement_per_nanomaterial]"
    nanos_with_multiple_elems = NanoMaterial.joins(:nano_elements)
                                            .group("nano_materials.id")
                                            .having("count(nano_material_id) > 1")

    affected_count = nanos_with_multiple_elems.count.size # .count returns a hash with the count for each nanomaterial
    Rails.logger.info "#{task_name} Found #{affected_count} nanomaterials associated with multiple nanoelements"
    Rails.logger.info "#{task_name} Associating each nanomaterial with a single nanoelement..."
    created_nanos = 0
    nanos_with_multiple_elems.each do |nanomaterial|
      nanomaterial.nano_elements.drop(1).each do |nanoelement| # All but first nanoelement
        ActiveRecord::Base.transaction do
          # Copy the original nanomaterial, including timestamps, save it as new record with different id.
          new_nanomaterial = NanoMaterial.create!(**nanomaterial.attributes.except("id"))
          nanomaterial.components.each { |component| new_nanomaterial.components << component }
          new_nanomaterial.save!
          nanoelement.update!(nano_material: new_nanomaterial)
        end
        created_nanos += 1
      end
    end
    Rails.logger.info "#{task_name} #{created_nanos} nanomaterials created and associated with nanoelements"
  end

  desc "Import nanoelements information into nanomaterials"
  task import_nanoelements_info: :environment do
    NanoMaterial.includes(:nano_elements).find_each do |nanomaterial|
      nano_element = nanomaterial.nano_elements.first
      nanomaterial.update!(inci_name: nano_element.inci_name,
                           inn_name: nano_element.inn_name,
                           iupac_name: nano_element.iupac_name,
                           xan_name: nano_element.xan_name,
                           cas_number: nano_element.cas_number,
                           ec_number: nano_element.ec_number,
                           einecs_number: nano_element.einecs_number,
                           elincs_number: nano_element.elincs_number,
                           purposes: nano_element.purposes,
                           confirm_toxicology_notified: nano_element.confirm_toxicology_notified,
                           confirm_usage: nano_element.confirm_usage,
                           confirm_restrictions: nano_element.confirm_restrictions)
    end
  end
end
