module ResponsiblePersons::NotificationsHelper
  def notification_summary_references_rows(notification)
    [
      {
        key: { html: "<abbr>UK</abbr> cosmetic product number".html_safe },
        value: { text: notification.reference_number_for_display },
      },
      if notification.cpnp_reference.present?
        {
          key: { html: "<abbr>EU</abbr> reference number".html_safe },
          value: { text: notification.cpnp_reference },
        }
      end,
      if notification.cpnp_notification_date.present?
        {
          key: { html: "First notified in the <abbr>EU</abbr>".html_safe },
          value: { text: display_full_month_date(notification.cpnp_notification_date) },
        }
      end,
      if notification.notification_complete_at.present?
        {
          key: { html: "<abbr>UK</abbr> notified".html_safe },
          value: { text: display_full_month_date(notification.notification_complete_at) },
        }
      end,
    ].compact
  end

  def notification_summary_product_rows(notification)
    [
      {
        key: { text: "Product name" },
        value: { text: notification.product_name },
        actions: {
          items: [
            {
              href: responsible_person_notification_product_path(notification.responsible_person, notification, :add_product_name),
              text: "Edit",
              visuallyHiddenText: "product name",
              classes: ["govuk-link--no-visited-state"],
            },
          ],
        },
      },
      if notification.industry_reference.present?
        {
          key: { text: "Internal reference number" },
          value: { text: notification.industry_reference },
          actions: {
            items: [
              {
                href: responsible_person_notification_product_path(notification.responsible_person, notification, :add_internal_reference),
                text: "Edit",
                visuallyHiddenText: "internal reference",
                classes: ["govuk-link--no-visited-state"],
              },
            ],
          },
        }
      end,
      unless notification.under_three_years.nil?
        {
          key: { text: "For children under 3" },
          value: { text: notification.under_three_years ? "Yes" : "No" },
          actions: {
            items: [
              {
                href: responsible_person_notification_product_path(notification.responsible_person, notification, :under_three_years),
                text: "Edit",
                visuallyHiddenText: "under three years",
                classes: ["govuk-link--no-visited-state"],
              },
            ],
          },
        }
      end,
      {
        key: { text: "Number of items" },
        value: { text: notification.components.length },
        actions: {
          items: [
            {
              href: responsible_person_notification_product_path(notification.responsible_person, notification, :single_or_multi_component),
              text: "Edit",
              visuallyHiddenText: "number of items",
              classes: ["govuk-link--no-visited-state"],
            },
          ],
        },
      },
      {
        key: { text: "Shades" },
        value: { html: display_shades(notification) },
        actions: {
          items: [
            {
              href: responsible_person_notification_product_path(notification.responsible_person, notification, :shades),
              text: "Edit",
              visuallyHiddenText: "shades",
              classes: ["govuk-link--no-visited-state"],
            },
          ],
        },
      },
      {
        key: { text: "Label" },
        value: { html: render("notifications/product_details_label_images",
                              notification:) },
        actions: {
          items: [
            {
              href: responsible_person_notification_product_path(notification.responsible_person, notification, :add_product_image),
              text: "Edit",
              visuallyHiddenText: "product image",
              classes: ["govuk-link--no-visited-state"],
            },
          ],
        },
      },
      {
        key: { text: "Are the items mixed?" },
        value: { text: notification.components_are_mixed ? "Yes" : "No" },
        actions: {
          items: [
            {
              href: new_responsible_person_notification_product_kit_path(notification.responsible_person, notification),
              text: "Edit",
              visuallyHiddenText: "mixed items",
              classes: ["govuk-link--no-visited-state"],
            },
          ],
        },
      },
      if can_view_product_ingredients? && notification.ph_min_value.present?
        {
          key: { html: "Minimum <abbr title='Power of hydrogen'>pH</abbr> value".html_safe },
          value: { text: notification.ph_min_value },
        }
      end,
      if can_view_product_ingredients? && notification.ph_max_value.present?
        {
          key: { html: "Maximum <abbr title='Power of hydrogen'>pH</abbr> value".html_safe },
          value: { text: notification.ph_max_value },
        }
      end,
    ].compact
  end

  def notification_summary_search_result_rows(notification)
    [
      {
        key: { text: "Product name" },
        value: { text: notification.product_name },
      },
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
                              notification:) },
      },
      {
        key: { text: "Are the items mixed?" },
        value: { text: notification.components_are_mixed ? "Yes" : "No" },
      },
      if can_view_product_ingredients? && notification.ph_min_value.present?
        {
          key: { html: "Minimum <abbr title='Power of hydrogen'>pH</abbr> value".html_safe },
          value: { text: notification.ph_min_value },
        }
      end,
      if can_view_product_ingredients? && notification.ph_max_value.present?
        {
          key: { html: "Maximum <abbr title='Power of hydrogen'>pH</abbr> value".html_safe },
          value: { text: notification.ph_max_value },
        }
      end,
    ].compact
  end

  def notification_summary_component_rows(component, include_shades: true)
    cmrs = component.cmrs
    nano_materials = component.nano_materials

    [
      if include_shades
        {
          key: { text: "Shades" },
          value: { html: render("none_or_bullet_list",
                                entities_list: component.shades,
                                list_classes: "",
                                list_item_classes: "") },
          actions: {
            items: [
              {
                href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :number_of_shades),
                text: "Edit",
                visuallyHiddenText: "#{component.name} category",
                classes: ["govuk-link--no-visited-state"],
              },
            ],
          },
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
                              entities_list: nano_materials_details(nano_materials),
                              list_classes: "",
                              list_item_classes: "") },
        actions: {
          items: [
            {
              href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :select_nanomaterials),
              text: "Edit",
              visuallyHiddenText: "select nanomaterials",
              classes: ["govuk-link--no-visited-state"],
            },
          ],
        },
      },
      if nano_materials.non_standard.any?
        {
          key: { text: "Nanomaterials review period end date" },
          value: { text: render("application/none_or_bullet_list",
                                entities_list: nano_materials_with_review_period_end_date(nano_materials.non_standard),
                                list_classes: "",
                                list_item_classes: "") },
        }
      end,
      if nano_materials.present?
        {
          key: { text: "Application instruction" },
          value: { text: get_exposure_routes_names(component.exposure_routes) },
          actions: {
            items: [
              {
                href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :add_exposure_routes),
                text: "Edit",
                visuallyHiddenText: "exposure root",
                classes: ["govuk-link--no-visited-state"],
              },
            ],
          },
        }
      end,
      if nano_materials.present?
        {
          key: { text: "Exposure condition" },
          value: { text: get_exposure_condition_name(component.exposure_condition) },
          actions: {
            items: [
              {
                href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :add_exposure_condition),
                text: "Edit",
                visuallyHiddenText: "exposure condition",
                classes: ["govuk-link--no-visited-state"],
              },
            ],
          },
        }
      end,
      {
        key: { text: "Category of product" },
        value: { text: get_category_name(component.root_category) },
        actions: {
          items: [
            {
              href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :select_root_category),
              text: "Edit",
              visuallyHiddenText: "#{component.name} category",
              classes: ["govuk-link--no-visited-state"],
            },
          ],
        },
      },
      {
        key: { text: "Category of #{get_category_name(component.root_category)&.downcase&.singularize}" },
        value: { text: get_category_name(component.sub_category) },
      },
      {
        key: { text: "Category of #{get_category_name(component.sub_category)&.downcase&.singularize}" },
        value: { text: get_category_name(component.sub_sub_category) },
      },
      {
        key: { text: "Physical form" },
        value: { text: get_physical_form_name(component.physical_form) },
        actions: {
          items: [
            {
              href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :add_physical_form),
              text: "Edit",
              visuallyHiddenText: "physical form",
              classes: ["govuk-link--no-visited-state"],
            },
          ],
        },

      },
      if can_view_product_ingredients?
        {
          key: { text: "Special applicator" },
          value: { text: component.special_applicator.present? ? "Yes" : "No" },
          actions: {
            items: [
              {
                href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :contains_special_applicator),
                text: "Edit",
                visuallyHiddenText: "contains special applicator",
                classes: ["govuk-link--no-visited-state"],
              },
            ],
          },
        }
      end,
      if can_view_product_ingredients? && component.special_applicator.present?
        {
          key: { text: "Applicator type" },
          value: { text: component_special_applicator_name(component) },
          actions: {
            items: [
              {
                href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :select_special_applicator_type),
                text: "Edit",
                visuallyHiddenText: "select special applicator type",
                classes: ["govuk-link--no-visited-state"],
              },
            ],
          },
        }
      end,
      if can_view_product_ingredients? && component.acute_poisoning_info.present?
        {
          key: { text: "Acute poisoning information" },
          value: { text: component.acute_poisoning_info },
        }
      end,
      if can_view_product_ingredients? && component.predefined?
        {
          key: { html: "Contains ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about".html_safe },
          value: { text: component.poisonous_ingredients_answer },
        }
      end,
      if can_view_product_ingredients? && component.predefined? && component.contains_poisonous_ingredients && component.formulation_file.present?
        {
          key: { html: "Ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about".html_safe },
          value: { html: render("notifications/component_details_poisonous_ingredients",
                                component:) },
        }
      end,
    ].concat(component_ph_trigger_questions_rows(component))
     .compact
  end

  def notification_summary_component_search_result_rows(component, include_shades: true)
    cmrs = component.cmrs
    nano_materials = component.nano_materials

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
                              entities_list: nano_materials_details(nano_materials),
                              list_classes: "",
                              list_item_classes: "") },
      },
      if nano_materials.non_standard.any?
        {
          key: { text: "Nanomaterials review period end date" },
          value: { text: render("application/none_or_bullet_list",
                                entities_list: nano_materials_with_review_period_end_date(nano_materials.non_standard),
                                list_classes: "",
                                list_item_classes: "") },
        }
      end,
      if nano_materials.present?
        {
          key: { text: "Application instruction" },
          value: { text: get_exposure_routes_names(component.exposure_routes) },
        }
      end,
      if nano_materials.present?
        {
          key: { text: "Exposure condition" },
          value: { text: get_exposure_condition_name(component.exposure_condition) },
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
      {
        key: { text: "Physical form" },
        value: { text: get_physical_form_name(component.physical_form) },
      },
      {
        key: { text: "Special applicator" },
        value: { text: component.special_applicator.present? ? "Yes" : "No" },
      },
      if component.special_applicator.present?
        {
          key: { text: "Applicator type" },
          value: { text: component_special_applicator_name(component) },
        }
      end,
      if component.acute_poisoning_info.present?
        {
          key: { text: "Acute poisoning information" },
          value: { text: component.acute_poisoning_info },
        }
      end,
      if component.predefined?
        {
          key: { html: "Contains ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about".html_safe },
          value: { text: component.poisonous_ingredients_answer },
        }
      end,
      if component.predefined? && component.contains_poisonous_ingredients && component.formulation_file.present?
        {
          key: { html: "Ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about".html_safe },
          value: { html: render("notifications/component_details_poisonous_ingredients",
                                component:) },
        }
      end,
    ].concat(component_ph_trigger_questions_rows(component))
     .compact
  end

  def notification_summary_label_image_link(image, responsible_person, notification)
    if image.passed_antivirus_check?
      link_to(image.filename, url_for(image.file), class: "govuk-link govuk-link--no-visited-state", target: "_blank", rel: "noopener")
    elsif image.pending_antivirus_check? && notification.editable?
      "#{image.file.filename} pending virus scan" \
      "<br>" \
      "#{link_to('Refresh', edit_responsible_person_notification_path(responsible_person, notification), class: 'govuk-link govuk-link--no-visited-state')}".html_safe
    elsif image.failed_antivirus_check?
      "#{image.file.filename} failed virus scan"
    end
  end

private

  def component_ph_trigger_questions_rows(component)
    return [] unless can_view_product_ingredients? && component.trigger_questions

    trigger_question_rows = component.trigger_questions.map(&method(:trigger_question_row))
    ph_row(component)
      .concat(trigger_question_rows)
      .compact
  end

  def ph_row(component)
    [
      {
        key: { html: ph_row_key_value(component) },
        value: { text: ph_row_text_value(component) },
        actions: ph_row_actions(component),
      },
    ]
  end

  def ph_row_key_value(component)
    return "<abbr title='Power of hydrogen'>pH</abbr>".html_safe if component.ph_range_not_required? || !component.ph_required?

    return "Exact <abbr title='Power of hydrogen'>pH</abbr>".html_safe if component.minimum_ph == component.maximum_ph

    "<abbr title='Power of hydrogen'>pH</abbr> range".html_safe
  end

  def ph_row_text_value(component)
    if component.ph_range_not_required?
      t(component.ph, scope: %i[component_ph check_your_answers])
    elsif !component.ph_required?
      "N/A"
    elsif component.minimum_ph == component.maximum_ph
      component.minimum_ph
    else
      "#{component.minimum_ph} to #{component.maximum_ph}"
    end
  end

  def ph_row_actions(component)
    return {} unless component.ph_required?

    {
      items: [
        {
          href: responsible_person_notification_component_build_path(component.notification.responsible_person, component.notification, component, :select_ph_option),
          text: "Edit",
          visuallyHiddenText: "select ph option",
          classes: ["govuk-link--no-visited-state"],
        },
      ],
    }
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
             value_name: :exact_concentration,
             list_classes: "")
    end
  end

  def trigger_question_row(trigger_question)
    return if trigger_question.ph_question?

    { key: { text: get_trigger_rules_short_question_name(trigger_question.question) },
      value: { html: trigger_question_elements_value(trigger_question.trigger_question_elements) } }
  end
end
