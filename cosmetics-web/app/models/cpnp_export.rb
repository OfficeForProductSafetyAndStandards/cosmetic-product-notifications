class CPNPExport
  def initialize(xml_file_content)
    @xml_doc = Nokogiri::XML(xml_file_content.gsub('sanco-xmlgate:', ''))
  end

  def product_name(_language = 'EN')
    name = @xml_doc.xpath("//currentVersion/generalInfo/productNameList/productName[language='EN']/name").first&.text
    name = @xml_doc.xpath("//currentVersion/generalInfo/productNameList/productName/name").first&.text if name.blank?
    name
  end

  def cpnp_reference
    @xml_doc.xpath('//cpnpReference').first&.text
  end

  def is_imported
    @xml_doc.xpath('//currentVersion/generalInfo/imported').first&.text&.casecmp?('Y')
  end

  def imported_country
    @xml_doc.xpath('//currentVersion/generalInfo/importedCty').first&.text
  end

  def shades
    @xml_doc.xpath('//currentVersion/generalInfo/productNameList/productName/shade').first&.text
  end
end
