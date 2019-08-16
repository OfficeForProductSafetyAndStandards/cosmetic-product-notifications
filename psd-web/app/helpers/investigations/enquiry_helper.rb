module Investigations::EnquiryHelper

  def other_date(form)
      render "form_components/govuk_date_input", form: form, key: :date_received,
      fieldset: { legend: { text: "When was it received?",  classes: "govuk-fieldset__legend--m"} }
  end

  def received_type(form)
      received_type_items = [{ text: "Email",
          value: "email"},
          { text: "Phone",
          value: "phone"},
          { text: "Other",
          value: "other",
          conditional: { html: other_type(form) } }]
  end

  def other_type(form)
      render "form_components/govuk_input", key: :other_received_type, form: form,
      label: { text: "" }
  end
end
