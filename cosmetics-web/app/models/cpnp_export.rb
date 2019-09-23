class CpnpExport
  include ::Shared::Web::CountriesHelper
  include CpnpNotificationProperties

  def initialize(xml_file_content, language = "EN")
    @xml_doc = Nokogiri::XML(xml_file_content.gsub("sanco-xmlgate:", ""))
    @language = language
  end

  def product_name
    get_attribute_with_language(current_version_product_names_node, ".//productName", "name")
  end

  def cpnp_reference
    @xml_doc.xpath("//cpnpReference").first&.text
  end

  def cpnp_notification_date
    dates = @xml_doc.xpath("//modificationDate").map { |element| Time.zone.parse(element.text) }
    dates.min
  end

  def industry_reference
    industry_reference = @xml_doc.xpath("//industryReference").first&.text
    industry_reference if industry_reference != "N/A"
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

  def under_three_years
    current_version_info_node.xpath(".//under3year").first&.text&.casecmp?("Y")
  end

  def still_on_the_market
    current_version_info_node.xpath(".//stillOnTheMarket").first&.text&.casecmp?("Y")
  end

  def components_are_mixed
    current_version_info_node.xpath(".//isMixed").first&.text&.casecmp?("Y")
  end

  def ph_min_value
    current_version_info_node.xpath(".//phMinValue").first&.text
  end

  def ph_max_value
    current_version_info_node.xpath(".//phMaxValue").first&.text
  end

  def shades
    get_attribute_with_language(current_version_product_names_node, ".//productName", "shade")
  end

  def components
    current_version_component_lists_node.xpath(".//component").collect do |component_node|
      Component.create!(name: component_name(component_node),
                       shades: component_shades(component_node),
                       notification_type: notification_type(component_node),
                       sub_sub_category: sub_sub_category(component_node),
                       frame_formulation: frame_formulation(component_node),
                       exact_formulas: exact_formulas(component_node),
                       range_formulas: range_formulas(component_node),
                       trigger_questions: trigger_questions(component_node),
                       cmrs: cmrs(component_node),
                       nano_material: nano_material(component_node),
                       physical_form: physical_form(component_node),
                       special_applicator: special_applicator(component_node),
                       acute_poisoning_info: acute_poisoning_info(component_node),
                       state: "component_complete",
                       minimum_ph: minimum_ph(component_node) || component_ph(component_node),
                       maximum_ph: maximum_ph(component_node) || component_ph(component_node))
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
    # TODO: COSBETA-401: save multiple exposure_routes
    NanoMaterial.create(exposure_condition: exposure_condition(nano_list_node),
                        exposure_routes: Array(exposure_routes(nano_list_node)),
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
    get_exposure_condition(nano_list_node&.xpath(".//exposureCondition")&.first&.text.to_i)
  end

  def exposure_routes(nano_list_node)
    get_exposure_route(nano_list_node&.xpath(".//exposureRoute/exposureID")&.first&.text.to_i)
  end

  def trigger_questions(component_node)
    trigger_questions = []

    component_node.xpath(".//quetionList/question").collect do |question_node|
      question_id = question_node.xpath('./questionID').first.content
      question_elements = question_node.xpath(".//questionElement")

      unless %w(100004 100023).include? question_id

        trigger_question_elements = question_elements.collect do |question_element_node|
          trigger_rules_element(question_element_node)
        end

        trigger_questions << TriggerQuestion.create(question: trigger_rules_question(question_node),
                               applicable: is_trigger_question_applicable(trigger_question_elements),
                               trigger_question_elements: trigger_question_elements)


      end
    end

    trigger_questions
  end

  def is_trigger_question_applicable(question_elements)
    question_elements.any? && applicable_inciname(question_elements) && applicable_ph(question_elements)
  end

  def applicable_inciname(question_elements)
    !(question_elements.size == 1 && question_elements.first.inciname? && question_elements.first.answer == "NA")
  end

  def applicable_ph(question_elements)
    !(question_elements.size == 1 && question_elements.first.ph? && question_elements.first.answer == "N")
  end

  def trigger_rules_element(question_element_node)
    TriggerQuestionElement.create!(answer_order: question_element_node.xpath(".//answerOrder").first&.text.to_i,
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
    get_attribute_with_language(component_node, ".//componentName", "name")
  end

  # Because CPNP stores shades as just a plain text field, we are unable to
  # extract the exported data into an array. As a workaround, we just return a
  # single element array containing the shades data, which should display as we
  # require.
  def component_shades(component_node)
    shades = get_attribute_with_language(component_node, ".//componentName", "shade")
    [shades]
  end

  def sub_sub_category(component_node)
    get_category(normalize_id(component_node.xpath(".//categorie3").first&.text))
  end

  def physical_form(component_node)
    get_physical_form(component_node.xpath(".//physicalForm").first&.text.to_i)
  end

  def special_applicator(component_node)
    return if component_node.xpath(".//specialApplicator") == "N"

    get_special_applicator(component_node.xpath(".//applicator").first&.text.to_i)
  end

  def acute_poisoning_info(component_node)
    component_node.xpath(".//acutePoisoningInfo").first&.text
  end

  def normalize_id(id_string)
    id_string.to_i < 100000 ? id_string.to_i + 100000 : id_string.to_i
  end

  def current_version_component_lists_node
    @xml_doc.xpath("//currentVersion/componentList")
  end

  def current_version_info_node
    @xml_doc.xpath("//currentVersion/generalInfo")
  end

  def current_version_product_names_node
    current_version_info_node.xpath(".//productNameList")
  end

  def get_gov_uk_country_code(cpnp_country_code)
    return if cpnp_country_code.length < 2

    country = all_countries.find { |c| c[1].include? cpnp_country_code }
    (country && country[1]) || cpnp_country_code
  end

  def get_attribute_with_language(node, path, attribute)
    selected_attribute = node.xpath("#{path}[language='#{@language}']/#{attribute}").first&.text
    selected_attribute = node.xpath("#{path}/#{attribute}").first&.text if selected_attribute.blank?
    selected_attribute
  end

  def minimum_ph(component_node)
    answer(component_node, question_id: '100023', element_id: '100037')
  end

  def maximum_ph(component_node)
    answer(component_node, question_id: '100023', element_id: '100038')
  end

  def component_ph(component_node)
    answer(component_node, question_id: '100004', element_id: '100005')
  end

  def answer(component_node, question_id:, element_id:)
    question_node = question_node_with_id(component_node, question_id)
    if question_node
      question_element_node = question_element_with_id(question_node, element_id)
      question_element_answer(question_element_node)
    end
  end

  def question_node_with_id(component_node, question_id)
    component_node.xpath(".//quetionList/question").detect do |question_node|
      question_node.xpath('./questionID')&.first&.content == question_id
    end
  end

  def question_element_with_id(question_node, element_id)
    question_node.xpath('./questionElement').detect do |question_element|
      question_element.xpath('./elementID')&.first&.content == element_id
    end
  end

  def question_element_answer(question_element_node)
    question_element_node.xpath('./answer')&.first&.content
  end
end
