namespace :cpnp_import do
  desc "Print static product data from CPNP"
  task :categories do
    print_three_mapping_data_structures('category', 'categories', 'category')
  end

  task :categories_parent do
    parent_hash_command = start_hash_command("PARENT_OF_CATEGORY")

    xml_file_content = File.read(Rails.root.join('app', 'assets', 'files', 'cpnp', 'categories.xml'))
    xml_doc = Nokogiri::XML(xml_file_content)

    underlined_names_set = Set.new
    xml_doc.xpath("//category[lngId='EN']").each do |english_category_node|
      english_category_name = english_category_node.xpath('name').first&.text
      underlined_name = get_underline_separated_name(english_category_name)
      while underlined_names_set.add?(underlined_name).blank?
        underlined_name = underlined_name + '_child'
      end

      parent_id = english_category_node.xpath('parentID').first&.text
      if parent_id.present?
        parent_english_category_name = xml_doc.xpath("//category[id=#{parent_id} and lngId='EN']/name").first&.text
        parent_underlined_name = get_underline_separated_name(parent_english_category_name)
        parent_hash_command += string_label_pair(underlined_name, parent_underlined_name)
      end
    end
    puts(end_command(parent_hash_command))
  end

  task :frame_formulations do
    print_three_mapping_data_structures('frame_formulation', 'frame_formulation', 'frameFormulation')
  end

  task :trigger_rules_questions do
    print_three_mapping_data_structures('trigger_rules_question', 'questions', 'question', 'id', 'description', false)
  end

  task :trigger_rules_question_elements do
    print_three_mapping_data_structures('trigger_rules_question_element', 'questions', 'element', 'elemID', 'elemName', false, false)
  end
end

def print_three_mapping_data_structures(variable_name, file_name, tag_name, id_tag_name = 'id', description_tag_name = 'name', enable_lang = true, enable_duplication = true)
  variable_name.upcase!
  enum_command = start_enum_command(variable_name)
  mapping_hash_command = start_hash_command("#{variable_name}_ID")
  view_hash_command = start_hash_command("#{variable_name}_NAME")

  xml_file_content = File.read(Rails.root.join('app', 'assets', 'files', 'cpnp', "#{file_name}.xml"))
  xml_doc = Nokogiri::XML(xml_file_content)

  underlined_names_set = Set.new

  query = "//#{tag_name}" + (enable_lang ? "[lngId='EN']" : "")
  xml_doc.xpath(query).each do |english_category_node|
    english_category_name = english_category_node.xpath(description_tag_name).first&.text
    id = english_category_node.xpath(id_tag_name).first&.text
    underlined_name = get_underline_separated_name(english_category_name)

    underlined_name_exist_in_set = underlined_names_set.add?(underlined_name).blank?
    if underlined_name_exist_in_set
      if enable_duplication
        while underlined_names_set.add?(underlined_name).blank?
          underlined_name = underlined_name + '_child'
        end
      end
    end
    if !underlined_name_exist_in_set || enable_duplication
      enum_command += string_string_pair(underlined_name, underlined_name)
      view_hash_command += string_string_pair(underlined_name, english_category_name.delete('"'))
    end

    mapping_hash_command += int_string_pair(id, underlined_name)
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
  "\t" + str1 + ': "' + str2 + '",' + "\n"
end

def string_label_pair(str1, label2)
  "\t" + str1 + ': :' + label2 + ",\n"
end

def int_string_pair(int1, str2)
  "\t" + int1 + ' => :' + str2 + ",\n"
end

def get_underline_separated_name(name)
  name.downcase.gsub(/[^a-zA-Z0-9\s]+/, '').gsub(/\s+/, '_')
end
