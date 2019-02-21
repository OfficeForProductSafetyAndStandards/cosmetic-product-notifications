module CPNPHelper
  def get_notification_type_name(notification_type)
    case notification_type
    when 1
      'predefined'
    when 2
      'exact'
    when 3
      'range'
    end
  end

  def get_category_name(category)
    xml_file_content = File.read(Rails.root.join('app', 'assets', 'files', 'cpnp', 'categories.xml'))
    xml_doc = Nokogiri::XML(xml_file_content)
    xml_doc.xpath("//category[lngId='EN' and id='#{category}']/name").first&.text
    end

  def get_parent_category(category)
    xml_file_content = File.read(Rails.root.join('app', 'assets', 'files', 'cpnp', 'categories.xml'))
    xml_doc = Nokogiri::XML(xml_file_content)
    xml_doc.xpath("//category[id='#{category}']/parentID").first&.text.to_i
  end

  def get_frame_formulation_name(frame_formulation)
    xml_file_content = File.read(Rails.root.join('app', 'assets', 'files', 'cpnp', 'frame_formulation.xml'))
    xml_doc = Nokogiri::XML(xml_file_content)
    xml_doc.xpath("//frameFormulation[lngId='EN' and id='#{frame_formulation}']/name").first&.text
  end
end
