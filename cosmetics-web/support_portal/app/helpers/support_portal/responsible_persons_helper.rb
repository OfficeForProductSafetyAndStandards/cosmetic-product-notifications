module SupportPortal
  module ResponsiblePersonsHelper
    def business_type_radios
      [
        OpenStruct.new(id: "business", name: "Limited company or Limited Liability Partnership (LLP)"),
        OpenStruct.new(id: "individual", name: "Individual or sole trader"),
      ]
    end

    def sort_order_icon(order)
      case order
      when "desc"
        "&#x25bc;"
      else
        "&#x25b2;"
      end
    end

    def company_name_sort_order_link(current_sort_order)
      sort_order = current_sort_order.nil? || current_sort_order == "asc" ? "desc" : "asc"
      query_string = { q: params[:q], company_name_sort_order: sort_order }.to_query
      "?#{query_string}"
    end

    def assigned_contact_sort_order_link(current_sort_order)
      sort_order = current_sort_order.nil? || current_sort_order == "asc" ? "desc" : "asc"
      query_string = { q: params[:q], assigned_contact_sort_order: sort_order }.to_query
      "?#{query_string}"
    end

    def responsible_person_address(responsible_person = nil)
      rp = responsible_person || @responsible_person
      [
        rp.address_line_1,
        rp.address_line_2,
        rp.city,
        rp.county,
        rp.postal_code,
      ].reject(&:blank?).join(", ")
    end

    def assigned_contact_details(assigned_contact)
      [
        assigned_contact&.name,
        assigned_contact&.email_address,
      ].reject(&:blank?).join("<br>")
    end

    def responsible_person_business_type(business_type = nil)
      type = business_type || @responsible_person.account_type
      {
        "individual" => "Individual or sole trader",
        "business" => "Limited company or Limited Liability Partnership (LLP)",
      }[type]
    end
  end
end
