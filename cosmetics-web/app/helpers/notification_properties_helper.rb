module NotificationPropertiesHelper
  def get_notification_type_name(notification_type)
    NOTIFICATION_TYPE[notification_type&.to_sym]
  end

  def get_frame_formulation_name(frame_formulation)
    (FrameFormulations::ALL_PLUS_OTHER_AND_VIEW_ONLY.deep_locate ->(key, value, _object) { key == "formulationId" && value == frame_formulation }).first&.dig("formulationName")
  end

  def get_trigger_rules_question_name(trigger_rules_question)
    TRIGGER_RULES_QUESTION_NAME[trigger_rules_question&.to_sym]
  end

  def get_trigger_rules_short_question_name(trigger_rules_question)
    TRIGGER_RULES_SHORT_QUESTION_NAME[trigger_rules_question&.to_sym]
  end

  def get_trigger_rules_question_element_name(trigger_rules_question_element)
    TRIGGER_RULES_QUESTION_ELEMENT_NAME[trigger_rules_question_element&.to_sym]
  end

  def get_unit_name(unit)
    UNIT_NAME[unit&.to_sym]
  end

  def get_exposure_routes_names(exposure_routes)
    exposure_routes&.map(&method(:get_exposure_route_name))&.join(", ")
  end

  def get_exposure_route_name(exposure_route)
    EXPOSURE_ROUTE_NAME[exposure_route&.to_sym]
  end

  def get_exposure_condition_name(exposure_condition)
    EXPOSURE_CONDITION_NAME[exposure_condition&.to_sym]
  end

  def get_physical_form_name(physical_form)
    PHYSICAL_FORM[physical_form&.to_sym]
  end

  def get_special_applicator_name(special_applicator)
    SPECIAL_APPLICATOR[special_applicator&.to_sym]
  end

  NOTIFICATION_TYPE = {
    predefined: "Frame formulation",
    exact: "Exact concentration",
    range: "Concentration ranges",
  }.freeze

  TRIGGER_RULES_QUESTION_NAME = {
    please_specify_the_percentage_weight_of_ethanol: "Please specify the percentage weight of ethanol.",
    please_specify_the_percentage_weight_of_isopropanol: "Please specify the percentage weight of isopropanol.",
    please_specify_the_inci_name_and_concentration_of_the_antidandruff_agents_if_antidandruff_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of the antidandruff agent(s).  If antidandruff agent(s) are not present in the cosmetic product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_concentration_of_the_antihair_loss_agents_if_antihair_loss_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of the anti-hair loss agent(s). If anti-hair loss agent(s) are not present in the cosmetic product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_concentration_of_the_antipigmenting_and_depigmenting_agents_if_antipigmenting_and_depigmenting_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of the anti-pigmenting and depigmenting agent(s). If anti-pigmenting and depigmenting agent(s) are not present in the cosmetic product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_concentration_of_chemical_exfoliating_agents_if_chemical_exfoliating_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of chemical exfoliating agents. If chemical exfoliating agent(s) are not present in the cosmetic product, then 'not applicable' must be checked.",
    please_specify_the_exact_content_of_vitamin_a_or_its_derivatives_for_the_whole_product_if_the_level_of_vitamin_a_or_any_of_its_derivatives_does_not_exceed_020_calculated_as_retinol_or_if_the_amount_does_not_exceed_009_grams_calculated_as_retinol_or_if_vitamin_a_or_any_of_its_derivatives_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please specify the exact content of vitamin A or its derivatives for the whole product. If the level of vitamin A or any of its derivatives does not exceed 0.20% (calculated as retinol) or if the amount does not exceed 0.09 grams (calculated as retinol) or if vitamin A or any of its derivatives are not present in the product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_the_concentration_of_xanthine_derivatives_eg_caffeine_theophylline_theobromine_plant_extracts_containing_xanthine_derivatives_eg_paulinia_cupana_guarana_extractspowders_if_xanthine_derivatives_are_not_present_or_present_below_05_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Please specify the INCI name and the concentration of xanthine derivatives (e.g. caffeine, theophylline, theobromine, plant extracts containing xanthine derivatives e.g. paulinia cupana (guarana) extracts/powders). If xanthine derivatives are not present or present below 0.5% in the cosmetic product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_concentration_of_the_cationic_surfactants_with_two_or_more_chain_lengths_below_c12_if_the_surfactant_is_used_for_non_preservative_purpose_if_cationic_surfactants_with_two_or_more_chain_lengths_below_c12_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of the cationic surfactants with two or more chain lengths below C12 if the surfactant is used for non preservative purpose. If cationic surfactants with two or more chain lengths below C12 are not present in the product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_concentration_of_each_propellant_if_propellants_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of each propellant. If propellants are not present in the product, then 'not applicable' must be checked.",
    please_specify_the_concentration_of_hydrogen_peroxide_if_hydrogen_peroxide_is_not_present_in_the_product_then_not_applicable_must_be_checked_: "Please specify the concentration of hydrogen peroxide. If hydrogen peroxide is not present in the product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_the_concentration_of_the_compounds_that_release_hydrogen_peroxide_if_compounds_releasing_hydrogen_peroxide_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please specify the INCI name and the concentration of the compounds that release hydrogen peroxide. If compounds releasing hydrogen peroxide are not present in the product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_concentration_of_each_reducing_agent_if_reducing_agents_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of each reducing agent. If reducing agent(s) are not present in the product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_concentration_of_each_persulfate_if_persulfates_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of each persulfate. If persulfate(s) are not present in the product, then 'not applicable' must be checked.",
    please_specify_the_inci_name_and_concentration_of_each_straightening_agent_if_straightening_agents_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please specify the INCI name and concentration of each straightening agent. If straightening agent(s) are not present in the product, then 'not applicable' must be checked.",
    please_indicate_the_total_concentration_of_inorganic_sodium_salts_if_inorganic_sodium_salts_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please indicate the total concentration of inorganic sodium salts. If inorganic sodium salts are not present in the product, then 'not applicable' must be checked.",
    please_indicate_the_concentration_of_fluoride_compounds_calculated_as_fluorine_if_fluoride_compounds_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Please indicate the concentration of fluoride compounds (calculated as Fluorine). If fluoride compounds are not present in the product, then 'not applicable' must be checked.",
    is_the_ph_of_the_component_lower_than_3_or_higher_than_10: "Is the pH of the component lower than 3 or higher than 10?",
    please_indicate_the_total_level_of_essential_oils_camphor_menthol_or_eucalyptol_if_essential_oils_camphor_menthol_or_eucalyptol_are_not_present_in_the_product_or_if_the_level_of_essential_oils_camphor_menthol_or_eucalyptol_does_not_exceed_05_then_not_applicable_must_be_checked: "Please indicate the total level of essential oils, camphor, menthol or eucalyptol. If essential oils, camphor, menthol or eucalyptol are not present in the product or if the level of essential oils, camphor, menthol or eucalyptol does not exceed 0.5%, then 'not applicable' must be checked.",
    please_indicate_the_name_and_the_quantity_of_each_essential_oil_camphor_menthol_or_eucalyptol_if_no_individual_essential_oil_camphor_menthol_or_eucalyptol_are_present_with_a_level_higher_than_05_015_in_case_of_camphor_then_not_applicable_must_be_checked: "Please indicate the name and the quantity of each essential oil, camphor, menthol or eucalyptol. If no individual essential oil, camphor, menthol or eucalyptol are present with a level higher than 0.5% (0.15 % in case of camphor), then 'not applicable' must be checked.",
    please_indicate_the_total_concentration_of_inorganic_sodium_salts: "Please indicate the total concentration of inorganic sodium salts.",
    please_indicate_the_ph_of_the_hair_dye_component: "Please indicate the pH of the hair dye component.",
    please_indicate_the_ph_of_the_mixed_hair_dye_product: "Please indicate the pH of the mixed hair dye product.",
    please_indicate_the_ph: "Please indicate the pH",
    please_indicate_the_ph_of_the_mixed_product_: "Please indicate the pH of the mixed product. ",
    do_the_components_of_the_product_need_to_be_mixed: "Do the components of the product need to be mixed?",
    please_indicate_the_inci_name_and_concentration_of_each_alkaline_agent_including_ammonium_hydroxide_liberators: "Please indicate the INCI name and concentration of each alkaline agent (including ammonium hydroxide liberators)",
  }.freeze

  TRIGGER_RULES_SHORT_QUESTION_NAME = {
    please_specify_the_percentage_weight_of_ethanol: "Ethanol",
    please_specify_the_percentage_weight_of_isopropanol: "Isopropanol",
    please_specify_the_inci_name_and_concentration_of_the_antidandruff_agents_if_antidandruff_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Anti-dandruff agents",
    please_specify_the_inci_name_and_concentration_of_the_antihair_loss_agents_if_antihair_loss_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Anti-hair loss agents",
    please_specify_the_inci_name_and_concentration_of_the_antipigmenting_and_depigmenting_agents_if_antipigmenting_and_depigmenting_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Anti-pigmenting and depigmenting agents",
    please_specify_the_inci_name_and_concentration_of_chemical_exfoliating_agents_if_chemical_exfoliating_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Chemical exfoliating agents",
    please_specify_the_exact_content_of_vitamin_a_or_its_derivatives_for_the_whole_product_if_the_level_of_vitamin_a_or_any_of_its_derivatives_does_not_exceed_020_calculated_as_retinol_or_if_the_amount_does_not_exceed_009_grams_calculated_as_retinol_or_if_vitamin_a_or_any_of_its_derivatives_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Vitamin A or its derivatives",
    please_specify_the_inci_name_and_the_concentration_of_xanthine_derivatives_eg_caffeine_theophylline_theobromine_plant_extracts_containing_xanthine_derivatives_eg_paulinia_cupana_guarana_extractspowders_if_xanthine_derivatives_are_not_present_or_present_below_05_in_the_cosmetic_product_then_not_applicable_must_be_checked: "Xanthine derivatives",
    please_specify_the_inci_name_and_concentration_of_the_cationic_surfactants_with_two_or_more_chain_lengths_below_c12_if_the_surfactant_is_used_for_non_preservative_purpose_if_cationic_surfactants_with_two_or_more_chain_lengths_below_c12_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Cationic surfactants",
    please_specify_the_inci_name_and_concentration_of_each_propellant_if_propellants_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Propellant",
    please_specify_the_concentration_of_hydrogen_peroxide_if_hydrogen_peroxide_is_not_present_in_the_product_then_not_applicable_must_be_checked_: "Hydrogen peroxide",
    please_specify_the_inci_name_and_the_concentration_of_the_compounds_that_release_hydrogen_peroxide_if_compounds_releasing_hydrogen_peroxide_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Compounds releasing hydrogen peroxide",
    please_specify_the_inci_name_and_concentration_of_each_reducing_agent_if_reducing_agents_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Reducing agents",
    please_specify_the_inci_name_and_concentration_of_each_persulfate_if_persulfates_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Persulfates",
    please_specify_the_inci_name_and_concentration_of_each_straightening_agent_if_straightening_agents_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Straightening agents",
    please_indicate_the_total_concentration_of_inorganic_sodium_salts_if_inorganic_sodium_salts_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Inorganic sodium salts",
    please_indicate_the_concentration_of_fluoride_compounds_calculated_as_fluorine_if_fluoride_compounds_are_not_present_in_the_product_then_not_applicable_must_be_checked: "Fluoride compounds",
    is_the_ph_of_the_component_lower_than_3_or_higher_than_10: "pH lower than 3 or higher than 10",
    please_indicate_the_total_level_of_essential_oils_camphor_menthol_or_eucalyptol_if_essential_oils_camphor_menthol_or_eucalyptol_are_not_present_in_the_product_or_if_the_level_of_essential_oils_camphor_menthol_or_eucalyptol_does_not_exceed_05_then_not_applicable_must_be_checked: "Total concentration of essential oils, camphor, menthol or eucalyptol",
    please_indicate_the_name_and_the_quantity_of_each_essential_oil_camphor_menthol_or_eucalyptol_if_no_individual_essential_oil_camphor_menthol_or_eucalyptol_are_present_with_a_level_higher_than_05_015_in_case_of_camphor_then_not_applicable_must_be_checked: "Essential oils, camphor, menthol or eucalyptol",
    please_indicate_the_total_concentration_of_inorganic_sodium_salts: "Inorganic sodium salts",
    please_indicate_the_ph_of_the_hair_dye_component: "Hair dye component pH",
    please_indicate_the_ph_of_the_mixed_hair_dye_product: "pH of mixed components",
    please_indicate_the_ph: "	Exact pH",
    please_indicate_the_ph_of_the_mixed_product_: "pH of mixed components",
    do_the_components_of_the_product_need_to_be_mixed: "Components mixed",
    please_indicate_the_inci_name_and_concentration_of_each_alkaline_agent_including_ammonium_hydroxide_liberators: "Alkaline agents",
  }.freeze

  TRIGGER_RULES_QUESTION_ELEMENT_NAME = {
    ethanol: "ethanol",
    propanol: "propanol",
    inciname: "inciName",
    incivalue: "inciValue",
    value: "value",
    ph: "ph",
    concentration: "concentration",
    minrangevalue: "minRangeValue",
    maxrangevalue: "maxRangeValue",
  }.freeze

  UNIT_NAME = {
    less_than_01_percent: "≤ 0.1",
    greater_than_01_less_than_1_percent: "> 0.1 and ≤ 1",
    greater_than_1_less_than_5_percent: "> 1 and ≤ 5",
    greater_than_5_less_than_10_percent: "> 5 and ≤ 10",
    greater_than_10_less_than_25_percent: "> 10 and ≤ 25",
    greater_than_25_less_than_50_percent: "> 25 and ≤ 50",
    greater_than_50_less_than_75_percent: "> 50 and ≤ 75",
    greater_than_75_less_than_100_percent: "> 75 and ≤ 100",
  }.freeze

  EXPOSURE_ROUTE_NAME = {
    dermal: "Dermal",
    oral: "Oral",
    inhalation: "Inhalation",
  }.freeze

  EXPOSURE_CONDITION_NAME = {
    rinse_off: "Rinsed off",
    leave_on: "Left on",
  }.freeze

  PHYSICAL_FORM = {
    solid_or_pressed_powder: "Solid or pressed powder",
    loose_powder: "Loose powder",
    cream_or_paste: "Cream or paste",
    liquid: "Liquid",
    foam: "Foam",
    spray: "Spray",
    other_physical_form: "Other",
  }.freeze

  SPECIAL_APPLICATOR = {
    wipe_sponge_patch_pad: "Wipe, sponge, patch or pad",
    encapsulated_products: "Encapsulated",
    pressurised_spray_container: "Pressurised spray",
    pressurised_container_non_spray_product: "Pressurised non-spray",
    other_special_applicator: "Other",
  }.freeze
end
