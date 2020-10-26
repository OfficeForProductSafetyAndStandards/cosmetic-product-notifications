namespace :cpnp_import do
  desc "Print static product categories data from CPNP"
  task categories: :environment do
    print_three_mapping_data_structures("category", "categories", "category")
  end

  desc "Print static product categories parent data from CPNP"
  task categories_parent: :environment do
    parent_hash_command = start_hash_command("PARENT_OF_CATEGORY")

    xml_file_content = File.read(Rails.root.join("app/assets/files/cpnp/categories.xml"))
    xml_doc = Nokogiri::XML(xml_file_content)

    category_key_names_set = Set.new
    xml_doc.xpath("//category[lngId='EN']").each do |english_category_node|
      english_category_name = english_category_node.xpath("name").first&.text
      category_key_name = get_category_key_name(english_category_name)
      category_key_name += "_child" while category_key_names_set.add?(category_key_name).blank?

      parent_id = english_category_node.xpath("parentID").first&.text
      next if parent_id.blank?

      parent_english_category_name = xml_doc.xpath("//category[id=#{parent_id} and lngId='EN']/name").first&.text
      parent_category_key_name = get_category_key_name(parent_english_category_name)
      parent_hash_command += label_string_pair(category_key_name, parent_category_key_name)
    end
    puts(end_command(parent_hash_command))
  end

  desc "Print static product frame formulations data from CPNP"
  task frame_formulations: :environment do
    print_three_mapping_data_structures("frame_formulation", "frameFormulation", "frameFormulation")
  end

  desc "Print static product trigger rules questions data from CPNP"
  task trigger_rules_questions: :environment do
    print_three_mapping_data_structures("trigger_rules_question", "questions", "question", "id", "description", false)
  end

  desc "Print static product trigger rules questions elements data from CPNP"
  task trigger_rules_question_elements: :environment do
    print_three_mapping_data_structures("trigger_rules_question_element", "questions", "element", "elemID", "elemName", false, false)
  end

  desc "Print static product units data from CPNP"
  task units: :environment do
    print_three_mapping_data_structures("unit", "units", "unit", "id", "name", false, false, true)
  end

  desc "Print static product exposure routes data from CPNP"
  task exposure_routes: :environment do
    print_three_mapping_data_structures("exposure_route", "exposureRoute", "exposureRoute")
  end

  desc "Print static product exposure conditions data from CPNP"
  task exposure_conditions: :environment do
    print_three_mapping_data_structures("exposure_condition", "exposureConditions", "exposureCondition")
  end
end

def print_three_mapping_data_structures(variable_name, file_name, main_tag, id_tag_name = "id", description_tag_name = "name",
                                        enable_lang = true, enable_duplication = true, enable_math_translation = false)
  variable_name.upcase!
  enum_command = start_enum_command(variable_name)
  mapping_hash_command = start_hash_command("#{variable_name}_ID")
  view_hash_command = start_hash_command("#{variable_name}_NAME")

  xml_file_content = File.read(Rails.root.join("app", "assets", "files", "cpnp", "#{file_name}.xml"))
  xml_doc = Nokogiri::XML(xml_file_content)

  category_key_names_set = Set.new

  query = "//#{main_tag}" + (enable_lang ? "[lngId='EN']" : "")
  xml_doc.xpath(query).each do |english_category_node|
    english_category_name = english_category_node.xpath(description_tag_name).first&.text
    id = english_category_node.xpath(id_tag_name).first&.text
    category_key_name = get_category_key_name(english_category_name, enable_math_translation)

    category_key_name_exist_in_set = category_key_names_set.add?(category_key_name).blank?
    if category_key_name_exist_in_set
      if enable_duplication
        category_key_name += "_child" while category_key_names_set.add?(category_key_name).blank?
      end
    end
    if !category_key_name_exist_in_set || enable_duplication
      enum_command += label_string_pair(category_key_name, category_key_name)
      view_hash_command += label_string_pair(category_key_name, english_category_name.delete('"'))
    end

    mapping_hash_command += int_string_pair(id, category_key_name)
  end

  puts(end_command(enum_command))
  puts(end_command(mapping_hash_command))
  puts(end_command(view_hash_command))
end

def start_enum_command(variable_name)
  "enum #{variable_name}: {\n"
end

def start_hash_command(variable_name)
  "#{variable_name} = {\n"
end

def end_command(command)
  command[0...-2] + "\n}"
end

def string_string_pair(str1, str2)
  "\t" + '"' + str1 + '": "' + str2 + '",' + "\n"
end

def label_string_pair(str1, str2)
  "\t" + str1 + ': "' + str2 + '",' + "\n"
end

def int_string_pair(int1, str2)
  "\t" + int1 + " => :" + str2 + ",\n"
end

def get_category_key_name(name, enable_math_translation = false)
  result = name
  if enable_math_translation
    result = name.gsub(/[≤<]+/, "less than")
                 .gsub(/[≥>]+/, "greater than")
                 .gsub(/[%]+/, " percent")
  end
  result.downcase.gsub(/[^a-zA-Z0-9\s]+/, "").gsub(/\s+/, "_")
end
