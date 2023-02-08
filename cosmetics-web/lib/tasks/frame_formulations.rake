namespace :frame_formulations do
  desc "Show the difference between the frame formulations in the category hierarchy and the definitions"
  task :diff, [:include_view_only] => :environment do |_t, args|
    args.with_defaults(include_view_only: false)

    hierarchy = Set.new
    definitions = Set.new
    view_only = Set.new

    # Get all frame formulations in the category hierarchy and deduplicate
    FrameFormulations::CATEGORIES.each do |_, sub_categories|
      sub_categories.each do |_, sub_sub_categories|
        sub_sub_categories.each do |_, frame_formulations|
          hierarchy.merge(frame_formulations)
        end
      end
    end

    # Get all frame formulations in the definitions and deduplicate
    FrameFormulations::ALL_PLUS_OTHER.each do |frame_formulations|
      frame_formulations["data"].each do |frame_formulation|
        definitions.add(frame_formulation["formulationId"])
      end
    end

    # Get all "view-only" frame formulations in the definitions and deduplicate
    [FrameFormulations::VIEW_ONLY].each do |frame_formulations|
      frame_formulations["data"].each do |frame_formulation|
        if ActiveModel::Type::Boolean.new.cast(args[:include_view_only])
          definitions.add(frame_formulation["formulationId"])
        else
          view_only.add(frame_formulation["formulationId"])
        end
      end
    end

    # Work out what's extra
    hierarchy_extras = hierarchy - definitions
    definition_extras = definitions - hierarchy

    puts "#{hierarchy.count} frame formulations in the category hierarchy"
    puts "#{definitions.count} frame formulations in the definitions"

    if hierarchy_extras.present?
      puts "Exist in the category hierarchy but not definitions:"
      hierarchy_extras.each do |e|
        exists_in_view_only = " (exists in view only list)" if view_only.include?(e)
        puts " * #{e}#{exists_in_view_only}"
      end
    end

    if definition_extras.present?
      puts "Exist in definitions but not the category hierarchy:"
      definition_extras.each { |e| puts " * #{e}" }
    end

    if hierarchy_extras.empty? && definition_extras.empty?
      puts "Category hierarchy and definitions match!"
    end
  end
end
