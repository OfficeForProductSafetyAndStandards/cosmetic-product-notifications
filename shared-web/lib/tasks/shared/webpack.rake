require "webpacker/configuration"

# TODO: Remove this once https://github.com/rails/webpacker/pull/1744 is merged / deployed
module Webpacker
  def clean(count_to_keep = 2)
    if config.public_output_path.exist? && config.public_manifest_path.exist?
      files_in_manifest = manifest.refresh.values.reject { |f| f.is_a?(Hash) }.map { |f| File.join config.root_path, "public", f }
      file_versions = files_in_manifest.flat_map do |file_in_manifest|
        file_prefix, file_ext = file_in_manifest.scan(/(.*)[0-9a-f]{20}(.*)/).first
        versions_of_file = Dir.glob("#{file_prefix}*#{file_ext}").grep(/#{file_prefix}[0-9a-f]{20}#{file_ext}/)
        versions_of_file.map do |version_of_file|
          next if version_of_file == file_in_manifest

          [version_of_file, File.mtime(version_of_file).utc.to_i]
        end
      end
      files_to_be_removed = file_versions.compact.sort_by(&:last).reverse.drop(count_to_keep).map(&:first)
      files_to_be_removed.each { |f| File.delete f }
    end
  end
end

namespace :webpacker do
  desc "Remove old compiled webpacks"
  task :clean, [:keep] => ["webpacker:verify_install", :environment] do |_, args|
    Webpacker.clean(Integer(args.keep || 2))
  end
end

# Run clean if the assets:clean is run
if Rake::Task.task_defined?("assets:clean")
  Rake::Task["assets:clean"].enhance do
    Rake::Task["webpacker:clean"].invoke
  end
else
  task "assets:clean": "webpacker:clean"
end
