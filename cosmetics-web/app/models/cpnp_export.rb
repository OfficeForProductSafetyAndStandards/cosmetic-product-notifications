class CpnpExport
  include ::Shared::Web::CountriesHelper
  include CpnpNotificationProperties

  def initialize(xml_file_content, language = "EN")
    @xml_doc = Nokogiri::XML(xml_file_content.gsub("sanco-xmlgate:", ""))
    @language = language
  end

  def product_name
    name = @xml_doc.xpath("//currentVersion/generalInfo/productNameList/productName[language='#{@language}']/name").first&.text
    name = @xml_doc.xpath("//currentVersion/generalInfo/productNameList/productName/name").first&.text if name.blank?
    name
  end

  def cpnp_reference
    @xml_doc.xpath("//cpnpReference").first&.text
  end

  def cpnp_notification_date
    dates = @xml_doc.xpath("//modificationDate").map { |element| Time.zone.parse(element.text) }
    dates.min
  end

  def industry_reference
    industry_reference_value = @xml_doc.xpath("//industryReference").first&.text
    industry_reference = if industry_reference_value == "N/A"
                           nil
                         else
                           industry_reference_value
                         end
    industry_reference
  end

  def notification_status
    @xml_doc.xpath('//status').first&.text
  end

  def is_imported
    current_version_info_node.xpath(".//imported").first&.text&.casecmp?("Y")
  end

  def imported_country
    get_gov_uk_country_code(current_version_info_node.xpath(".//importedCty").first&.text)
  end

  def shades
    current_version_info_node.xpath(".//shade").first&.text
  end

  def components
    current_version_component_lists_node.xpath(".//component").collect do |component_node|
      Component.create(name: component_name(component_node),
                       shades: component_shades(component_node),
                       notification_type: notification_type(component_node),
                       sub_sub_category: sub_sub_category(component_node),
                       frame_formulation: frame_formulation(component_node),
                       exact_formulas: exact_formulas(component_node),
                       range_formulas: range_formulas(component_node),
                       trigger_questions: trigger_questions(component_node),
                       cmrs: cmrs(component_node),
                       nano_material: nano_material(component_node))
    end
  end

private

  def cmrs(component_node)
    return if component_node.xpath(".//hasCmr") == "N"

    component_node.xpath(".//cmrList/cmr").collect do |cmr_node|
      Cmr.create(name: cmr_node.xpath(".//name").first&.text,
                 cas_number: cmr_node.xpath(".//casNumber").first&.text,
                 ec_number: cmr_node.xpath(".//ecNumber").first&.text)
    end
  end

  def nano_material(component_node)
    return if component_node.xpath(".//hasNano") == "N"

    nano_list_node = component_node.xpath(".//nanoList").first
    nano_elements = nano_list_node&.xpath(".//nano")&.collect do |nano_element_node|
      nano_element(nano_element_node)
    end
    NanoMaterial.create(exposure_condition: exposure_condition(nano_list_node),
                        exposure_route: exposure_route(nano_list_node),
                        nano_elements: nano_elements)
  end

  def nano_element(nano_element_node)
    NanoElement.create(inci_name: nano_element_node.xpath(".//inciName").first&.text,
                       inn_name: nano_element_node.xpath(".//innName").first&.text,
                       iupac_name: nano_element_node.xpath(".//iupacName").first&.text,
                       xan_name: nano_element_node.xpath(".//xanName").first&.text,
                       cas_number: nano_element_node.xpath(".//casNumber").first&.text,
                       ec_number: nano_element_node.xpath(".//ecNumber").first&.text,
                       einecs_number: nano_element_node.xpath(".//einecsNumber").first&.text,
                       elincs_number: nano_element_node.xpath(".//elincsNumber").first&.text)
  end

  def exposure_condition(nano_list_node)
    get_exposure_condition(nano_list_node&.xpath(".//exposureCondition")&.first&.text)
  end

  def exposure_route(nano_list_node)
    get_exposure_route(nano_list_node&.xpath(".//exposureRoute/exposureID")&.first&.text)
  end

  def trigger_questions(component_node)
    component_node.xpath(".//quetionList/question").collect do |question_node|
      question_elements = question_node.xpath(".//questionElement").collect do |question_element_node|
        trigger_rules_element(question_element_node)
      end
      TriggerQuestion.create(question: trigger_rules_question(question_node),
                             trigger_question_elements: question_elements)
    end
  end

  def trigger_rules_element(question_element_node)
    TriggerQuestionElement.create(answer_order: question_element_node.xpath(".//answerOrder").first&.text.to_i,
                                  answer: question_element_node.xpath(".//answer").first&.text,
                                  element_order: question_element_node.xpath(".//elementOrder").first&.text.to_i,
                                  element: get_trigger_rules_question_element(normalize_id(question_element_node.xpath(".//elementID").first&.text)))
  end

  def trigger_rules_question(question_node)
    get_trigger_rules_question(normalize_id(question_node.xpath(".//questionID").first&.text))
  end

  def exact_formulas(component_node)
    component_node.xpath(".//exactFormulaList/formula").collect do |formula_node|
      ExactFormula.create(inci_name: formula_node.xpath(".//inciName").first&.text,
                          quantity: formula_node.xpath(".//quantity").first&.text)
    end
  end

  def range_formulas(component_node)
    component_node.xpath(".//rangeFormulaList/formula").collect do |formula_node|
      RangeFormula.create(inci_name: formula_node.xpath(".//inciName").first&.text,
                          range: get_unit(formula_node.xpath(".//range").first&.text.to_i))
    end
  end

  def frame_formulation(component_node)
    get_frame_formulation(normalize_id(component_node.xpath(".//frameFormulation").first&.text))
  end

  def notification_type(component_node)
    get_notification_type(component_node.xpath(".//notificationType").first&.text.to_i)
  end

  def component_name(component_node)
    component_node.xpath(".//componentName[language='#{@language}']/name").first&.text
  end

  def component_shades(component_node)
    component_node.xpath(".//componentName[language='#{@language}']/shade").first&.text
  end

  def sub_sub_category(component_node)
    get_category(normalize_id(component_node.xpath(".//categorie3").first&.text))
  end

  def normalize_id(id_string)
    id_string.to_i < 100000 ? id_string.to_i + 100000 : id_string.to_i
  end

  def current_version_component_lists_node
    current_version_info_node.xpath("//currentVersion/componentList")
  end

  def current_version_info_node
    @xml_doc.xpath("//currentVersion/generalInfo")
  end

  def get_gov_uk_country_code(cpnp_country_code)
    return if cpnp_country_code.length < 2

    country = all_countries.find { |c| c[1].include? cpnp_country_code }
    (country && country[1]) || cpnp_country_code
  end
end
