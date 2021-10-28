module ResponsiblePersons::NotificationsHelper
  def notification_summary_references_rows(notification)
    [
      {
        key: { html: "<abbr title='United Kingdom'>UK</abbr> cosmetic product number".html_safe },
        value: { text: notification.reference_number_for_display },
      },
      if notification.cpnp_reference.present?
        {
          key: { html: "<abbr title='European Union'>EU</abbr> reference number".html_safe },
          value: { text: notification.cpnp_reference },
        }
      end,
      if notification.cpnp_notification_date.present?
        {
          key: { html: "First notified in the <abbr title='European Union'>EU</abbr>".html_safe },
          value: { text: display_full_month_date(notification.cpnp_notification_date) },
        }
      end,
    ].compact
  end

  def notification_summary_product_rows(notification, allow_edits: false)
    [
      {
        key: { text: "Product name" },
        value: { text: notification.product_name },
      },
      if notification.industry_reference.present?
        {
          key: { text: "Internal reference number" },
          value: { text: notification.industry_reference },
        }
      end,
      unless notification.under_three_years.nil?
        {
          key: { text: "For children under 3" },
          value: { text: notification.under_three_years ? "Yes" : "No" },
        }
      end,
      {
        key: { text: "Number of items" },
        value: { text: notification.components.length },
      },
      {
        key: { text: "Shades" },
        value: { html: display_shades(notification) },
      },
      {
        key: { text: "Label image" },
        value: { html: render("notifications/product_details_label_images",
                              notification: notification,
                              allow_edits: allow_edits) },
        actions: { items: allow_edits ? label_image_actions_items(notification) : [] },
      },
      {
        key: { text: "Are the items mixed?" },
        value: { text: notification.components_are_mixed ? "Yes" : "No" },
      },
      if current_user.can_view_product_ingredients? && notification.ph_min_value.present?
        {
          key: { html: "Minimum <abbr title='Power of hydrogen'>pH</abbr> value".html_safe },
          value: { text: notification.ph_min_value },
        }
      end,
      if current_user.can_view_product_ingredients? && notification.ph_max_value.present?
        {
          key: { html: "Maximum <abbr title='Power of hydrogen'>pH</abbr> value".html_safe },
          value: { text: notification.ph_max_value },
        }
      end,
    ].compact
  end

  def notification_summary_component_rows(component, include_shades: true, allow_edits: false)
    cmrs = component.cmrs
    nano_material = component.nano_material

    [
      if include_shades
        {
          key: { text: "Shades" },
          value: { html: render("none_or_bullet_list",
                                entities_list: component.shades,
                                list_classes: "",
                                list_item_classes: "") },
        }
      end,
      {
        key: { html: "Contains <abbr title='Carcinogenic, mutagenic, reprotoxic'>CMR</abbr> substances".html_safe },
        value: { text: cmrs.any? ? "Yes" : "No" },
      },
      if cmrs.any?
        {
          key: { html: "<abbr title='Carcinogenic, mutagenic, reprotoxic'>CMR</abbr> substances".html_safe },
          value: { html: render("application/none_or_bullet_list",
                                entities_list: cmrs.map(&:display_name),
                                list_classes: "",
                                list_item_classes: "") },
        }
      end,
      {
        key: { text: "Nanomaterials" },
        value: { html: render("application/none_or_bullet_list",
                              entities_list: nano_material&.nano_elements&.map(&:display_name),
                              list_classes: "",
                              list_item_classes: "") },
      },
      if nano_material&.nano_elements.present?
        {
          key: { text: "Application instruction" },
          value: { text: get_exposure_routes_names(nano_material.exposure_routes) },
        }
      end,
      if nano_material&.nano_elements.present?
        {
          key: { text: "Exposure condition" },
          value: { text: get_exposure_condition_name(nano_material.exposure_condition) },
        }
      end,
      {
        key: { text: "Category of product" },
        value: { text: get_category_name(component.root_category) },
      },
      {
        key: { text: "Category of #{get_category_name(component.root_category)&.downcase&.singularize}" },
        value: { text: get_category_name(component.sub_category) },
      },
      {
        key: { text: "Category of #{get_category_name(component.sub_category)&.downcase&.singularize}" },
        value: { text: get_category_name(component.sub_sub_category) },
      },
      if current_user.can_view_product_ingredients?
        {
          key: { text: "Formulation given as" },
          value: { text: get_notification_type_name(component.notification_type) },
        }
      end,
      if current_user.can_view_product_ingredients? && component.predefined?
        {
          key: { text: "Frame formulation" },
          value: { text: get_frame_formulation_name(component.frame_formulation) },
        }
      end,
      if current_user.can_view_product_ingredients? && !component.predefined?
        {
          key: { text: "Formulation" },
          value: { html: render("notifications/component_details_formulation_ingredients",
                                component: component,
                                allow_edits: allow_edits) },
          actions: { items: allow_edits ? componment_formulation_actions_items(component) : [] },
        }
      end,
      {
        key: { text: "Physical form" },
        value: { text: get_physical_form_name(component.physical_form) },
      },
      if current_user.can_view_product_ingredients?
        {
          key: { text: "Special applicator" },
          value: { text: component.special_applicator.present? ? "Yes" : "No" },
        }
      end,
      if current_user.can_view_product_ingredients? && component.special_applicator.present?
        {
          key: { text: "Applicator type" },
          value: { text: component_special_applicator_name(component) },
        }
      end,
      if current_user.can_view_product_ingredients?
        {
          key: { text: "Acute poisoning information" },
          value: { text: component.acute_poisoning_info },
        }
      end,
      if current_user.can_view_product_ingredients? && component.predefined?
        {
          key: { html: "Contains ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about".html_safe },
          value: { text: component.poisonous_ingredients_answer },
        }
      end,
      if current_user.can_view_product_ingredients? && component.predefined? && component.contains_poisonous_ingredients
        {
          key: { html: "Ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about".html_safe },
          value: { html: render("notifications/component_details_poisonous_ingredients",
                                component: component,
                                allow_edits: allow_edits) },
        }
      end,
    ].concat(component_ph_trigger_questions_rows(component))
     .compact
  end

private

  def label_image_actions_items(notification)
    return [] if notification.image_uploads.blank?

    [{ href: edit_responsible_person_notification_product_images_path(notification.responsible_person, notification),
       text: "Change",
       visuallyHiddenText: "label image",
       classes: "govuk-link--no-visited-state" }]
  end

  def componment_formulation_actions_items(component)
    return [] unless component.formulation_file.attached?

    notification = component.notification
    [{ href: edit_responsible_person_notification_component_formulation_path(notification.responsible_person, notification, component),
       text: "Change",
       visuallyHiddenText: "formulation file",
       classes: "govuk-link--no-visited-state" }]
  end

  def component_ph_trigger_questions_rows(component)
    return [] unless current_user.can_view_product_ingredients? && component.trigger_questions

    trigger_question_rows = component.trigger_questions.map(&method(:trigger_question_row))
    ph_row(component)
      .concat(trigger_question_rows)
      .compact
  end

  def ph_row(component)
    [
      if component.ph_range_not_required?
        {
          key: { html: "<abbr title='Power of hydrogen'>pH</abbr>".html_safe },
          value: { text: t(component.ph, scope: %i[component_ph check_your_answers]) },
        }
      elsif component.minimum_ph == component.maximum_ph
        {
          key: { html: "Exact <abbr title='Power of hydrogen'>pH</abbr>".html_safe },
          value: { text: component.minimum_ph },
        }
      else
        {
          key: { html: "<abbr title='Power of hydrogen'>pH</abbr> range".html_safe },
          value: { text: "#{component.minimum_ph} to #{component.maximum_ph}" },
        }
      end,
    ]
  end

  def trigger_question_element_value(element)
    if element.value_given_as_concentration?
      display_concentration(element.answer)
    else
      format_trigger_question_answers(element.answer)
    end
  end

  def trigger_question_elements_value(elements)
    if elements.count == 1
      trigger_question_element_value(elements.first)
    else
      render("none_or_bullet_list",
             entities_list: format_trigger_question_elements(elements),
             key_name: :inci_name,
             value_name: :quantity,
             list_classes: "")
    end
  end

  def trigger_question_row(trigger_question)
    return [] if trigger_question.ph_question?

    [{ key: { text: get_trigger_rules_short_question_name(trigger_question.question) },
       value: { html: trigger_question_elements_value(trigger_question.trigger_question_elements) } }]
  end
end
