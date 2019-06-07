module NanomaterialHelper
  def nano_elements_purposes
    {
        colorant: "Colorant",
        preservative: "Preservative",
        uv_filter: "UV filter",
        other: "Another purpose"
    }
  end

  def get_ec_regulation_annex_number_for_nano_material_purpose(purpose)
    ec_regulation_annex_number_for_nano_material_purpose[purpose&.to_sym]
  end

  def get_ec_regulation_link_for_annex_number(annex_number)
    case annex_number
    when 4
      "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223#d1e32-176-1"
    when 5
      "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223#d1e32-192-1"
    when 6
      "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223#d1e32-201-1"
    else
      "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223"
    end
  end

private

  def ec_regulation_annex_number_for_nano_material_purpose
    {
        colorant: 4,
        preservative: 5,
        uv_filter: 6
    }
  end
end
