class CPNPExport
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

  def is_imported
    current_version_info_node.xpath('.//imported').first&.text&.casecmp?('Y')
  end

  def imported_country
    get_gov_uk_country_code(current_version_info_node.xpath('.//importedCty').first&.text)
  end

  def shades
    current_version_info_node.xpath('.//shade').first&.text
  end

  def components
    current_version_component_lists_node.xpath('.//component').collect do |component_node|
      Component.create(notification_type: notification_type(component_node),
                       frame_formulation: frame_formulation(component_node),
                       exact_formulas: exact_formulas(component_node),
                       range_formulas: range_formulas(component_node),
                       trigger_questions: trigger_questions(component_node))
    end
  end

private
  def trigger_questions(component_node)
    component_node.xpath('.//quetionList/question').collect do |question_node|
      question_id = question_node.xpath('.//questionID').first&.text.to_i
      question_elements = question_node.xpath('.//questionElement').collect do |question_element_node|
        TriggerQuestionElement.create(answer_order: question_element_node.xpath('.//answerOrder').first&.text.to_i,
                                      answer: question_element_node.xpath('.//answer').first&.text,
                                      element_id: question_element_node.xpath('.//elementID').first&.text.to_i,
                                      element_order: question_element_node.xpath('.//elementOrder').first&.text.to_i)
      end
      TriggerQuestion.create(question_id: question_id,
                             trigger_question_elements: question_elements)
    end
  end

  def exact_formulas(component_node)
    component_node.xpath('.//exactFormulaList/formula').collect do |formula_node|
      ExactFormula.create(inci_name: formula_node.xpath('.//inciName').first&.text,
                          quantity: formula_node.xpath('.//quantity').first&.text)
    end
  end

  def range_formulas(component_node)
    component_node.xpath('.//rangeFormulaList/formula').collect do |formula_node|
      RangeFormula.create(inci_name: formula_node.xpath('.//inciName').first&.text,
                          range: formula_node.xpath('.//range').first&.text)
    end
  end

  def frame_formulation(component_node)
    component_node.xpath('.//frameFormulation').first&.text.to_i
  end

  def notification_type(component_node)
    # notification_type: [ predefined: 1, exact: 2, range: 3 ]
    component_node.xpath('.//notificationType').first&.text.to_i
  end

  def current_version_component_lists_node
    current_version_info_node.xpath('//currentVersion/componentList')
  end

  def current_version_info_node
    @xml_doc.xpath('//currentVersion/generalInfo')
  end

  def get_gov_uk_country_code(cpnp_country_code)
    return if cpnp_country_code.length < 2

    country = all_countries.find { |c| c[1].include? cpnp_country_code }
    (country && country[1]) || cpnp_country_code
  end
end
