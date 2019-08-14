module Investigations::EnquiryHelper
    def date_received(form)
        date_received_items = [{ key: "today",
            text: "Today",
            value: "2001-10-05",
            unchecked_value: "unchecked" },
            { key: "yesterday",
            text: "Yesterday",
            value: "yesterday",
            unchecked_value: "unchecked" },
            { key: "other",
            text: "Other date",
            value: "other",
            checked: "other",
            unchecked_value: "unchecked",
            conditional: { html: other_date(form) } }]
    end

    def other_date(form)
        render "form_components/govuk_date_input", form: form, key: :date_received,
        fieldset: { legend: { classes: "govuk-fieldset__legend--m"} }
    end

    def received_type(form)
        received_type_items = [{ key: "email",
            text: "Email",
            value: "email",
            unchecked_value: "unchecked" },
            { key: "phone",
            text: "Phone",
            value: "phone",
            unchecked_value: "unchecked" },
            { key: "other",
            text: "Other",
            value: "other",
            checked: "other_type",
            unchecked_value: "unchecked",
            conditional: { html: other_type(form) } }]
    end

    def other_type(form)
        render "form_components/govuk_input", key: :other_type, form: form,
        label: { text: "Other" }
    end
end
