class CpnpExport
  include ::Shared::Web::CountriesHelper

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

  def notification_status
    @xml_doc.xpath('//status').first&.text
  end

  def is_imported
    @xml_doc.xpath('//currentVersion/generalInfo/imported').first&.text&.casecmp?('Y')
  end

  def imported_country
    get_gov_uk_country_code(@xml_doc.xpath('//currentVersion/generalInfo/importedCty').first&.text)
  end

  def shades
    @xml_doc.xpath('//currentVersion/generalInfo/productNameList/productName/shade').first&.text
  end

private

  def get_gov_uk_country_code(cpnp_country_code)
    return if cpnp_country_code.length < 2

    country = all_countries.find { |c| c[1].include? cpnp_country_code }
    (country && country[1]) || cpnp_country_code
  end
end
