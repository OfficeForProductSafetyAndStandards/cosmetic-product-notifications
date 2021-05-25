module CategoryHelper
  CATEGORY_NAME = {
    skin_products: "Skin products",
    skin_care_products: "Skin care products",
    face_care_products_other_than_face_mask: "Face care products other than face mask",
    face_mask: "Face mask",
    eye_contour_products: "Eye contour products",
    lip_care_products: "Lip care products",
    hand_care_products: "Hand care products",
    foot_care_products: "Foot care products",
    body_care_products: "Body care products",
    external_intimate_care_products: "External intimate care products",
    chemical_exfoliation_products: "Chemical exfoliation products",
    mechanical_exfoliation_products: "Mechanical exfoliation products",
    skin_lightening_products: "Skin lightening products",
    other_skin_care_products: "Other skin care products",
    skin_cleansing_products: "Skin cleansing products",
    soap_products: "Soap products",
    bath_shower_products: "Bath / shower products",
    makeup_remover_products: "Make-up remover products",
    external_intimate_hygiene_products: "External Intimate hygiene products",
    other_skin_cleansing_products: "Other skin cleansing products",
    body_hair_removal_products: "Body hair removal products",
    chemical_depilatories: "Chemical depilatories",
    physical_epilation_products: "Physical  epilation products",
    other_body_hair_removal_products: "Other body hair removal products",
    bleach_for_body_hair_products: "Bleach for body hair products",
    bleach_for_body_hair: "Bleach for body hair",
    correction_of_body_odour_andor_perspiration: "Correction of body odour and/or perspiration",
    products_with_antiperspirant_activity: "Products with antiperspirant activity",
    products_without_antiperspirant_activity: "Products without antiperspirant activity",
    shaving_and_pre_after_shaving_products: "Shaving and pre- / after- shaving products",
    shaving_products: "Shaving products",
    pre_aftershaving_products: "Pre- / after-shaving products",
    other_shaving_and_pre_after_shaving_products: "Other shaving and pre- / after- shaving products",
    makeup_products: "Make-up products",
    foundation: "Foundation",
    concealer: "Concealer",
    other_face_makeup_products: "Other face make-up products",
    mascara: "Mascara",
    eye_shadow: "Eye shadow",
    eye_pencil: "Eye pencil",
    eye_liner: "Eye liner",
    other_eye_makeup_products: "Other eye make-up products",
    lip_stick: "Lip stick",
    lipstick_sealer: "Lipstick sealer",
    other_lip_makeup_products: "Other lip make-up products",
    body_or_face_paint_including_carneval_makeup: "Body or face paint , including carneval make-up",
    other_makeup_products: "Other make-up products",
    perfumes: "Perfumes",
    hydroalcoholic_perfumes: "Hydroalcoholic perfumes",
    non_hydroalcoholic_perfumes: "Non hydroalcoholic perfumes",
    sun_and_selftanning_products: "Sun and self-tanning products",
    before_and_after_sun_products: "Before and after sun products",
    sun_protection_products: "Sun protection products",
    selftanning_products: "Self-tanning products",
    other_sun_and_selftanning_products: "Other sun and self-tanning products",
    other_skin_products: "Other skin products",
    other_skin_products_child: "Other skin products",
    hair_and_scalp_products: "Hair and scalp products",
    hair_and_scalp_care_and_cleansing_products: "Hair and scalp care and cleansing products",
    shampoo: "Shampoo",
    hair_conditioner: "Hair conditioner",
    scalp_and_hair_roots_care_products: "Scalp and hair roots care products",
    antidandruff_products: "Antidandruff products",
    antihairloss_products: "Antihairloss products",
    other_hair_and_scalp_care_and_cleansing_products: "Other hair and scalp care and cleansing products",
    hair_colouring_products: "Hair colouring products",
    oxidative_hair_colour_products: "Oxidative hair colour products",
    nonoxidative_hair_colour_products: "Non-oxidative hair colour products",
    hair_bleaching_and_dye_remover_products: "Hair bleaching and dye remover products",
    other_hair_colouring_products: "Other hair colouring products",
    hair_styling_products: "Hair styling products",
    products_for_temporary_hair_styling: "Products for temporary hair styling",
    permanent_wave_products: "Permanent wave products",
    hair_relaxer_straightener_products: "Hair relaxer / straightener products",
    other_hair_styling_products: "Other hair styling products",
    other_hair_and_scalp_products: "Other hair and scalp products",
    hair_sun_protection_products: "Hair sun protection products",
    other_hair_and_scalp_products_child: "Other hair and scalp products",
    nail_and_cuticle_products: "Nail and cuticle products",
    nail_varnish_and_remover_products: "Nail varnish and remover products",
    nail_varnish_nail_makeup: "Nail varnish / Nail make-up",
    nail_varnish_remover: "Nail varnish remover",
    nail_varnish_thinner: "Nail varnish thinner",
    nail_bleach: "Nail bleach",
    other_nail_varnish_and_remover_products: "Other nail varnish and remover products",
    nail_care_nail_hardener_products: "Nail care / nail hardener products",
    nail_care_products: "Nail care products",
    nail_hardener: "Nail hardener",
    other_nail_care_nail_hardener_products: "Other nail care / nail hardener products",
    nail_glue_remover_products: "Nail glue remover products",
    nail_glue_remover: "Nail glue remover",
    other_nail_and_cuticle_products: "Other nail and cuticle products",
    cuticle_remover_softener: "Cuticle remover / softener",
    nail_sculpting_products: "Nail sculpting products",
    other_nail_and_cuticle_products_child: "Other nail and cuticle products",
    oral_hygiene_products: "Oral hygiene products",
    tooth_care_products: "Tooth care products",
    toothpaste: "Toothpaste",
    tooth_cleansing_powder_salt: "Tooth cleansing powder / salt",
    other_tooth_care_products: "Other tooth care products",
    mouth_wash_breath_spray: "Mouth wash / breath spray",
    mouth_wash: "Mouth wash",
    breath_spray: "Breath spray",
    other_mouth_wash_breath_spray_products: "Other mouth wash / breath spray products",
    tooth_whiteners: "Tooth whiteners",
    tooth_whiteners_child: "Tooth whiteners",
    other_oral_hygiene_products: "Other oral hygiene products",
    other_oral_hygiene_products_child: "Other oral hygiene products",
  }.freeze

  def get_category_name(category)
    CATEGORY_NAME[category&.to_sym]
  end

  def full_category_display_name(component)
    component.display_root_category + ", " + \
      component.display_sub_category + ", " + \
      component.display_sub_sub_category
  end

  def get_full_category_name(sub_sub_category)
    sub_category = Component.get_parent_category(sub_sub_category.to_sym)
    "#{get_category_name(sub_category)} - #{get_category_name(sub_sub_category)}"
  end

  def get_main_categories
    parent_of_categories = Component.get_parent_of_categories
    Component.categories.reject { |category| parent_of_categories[category.to_sym].present? }.keys.map(&:to_sym)
  end

  def get_sub_categories(category)
    Component.get_parent_of_categories.select { |_key, value| value == category.to_sym }.keys
  end

  def has_sub_categories(category)
    get_sub_categories(category).any?
  end
end
