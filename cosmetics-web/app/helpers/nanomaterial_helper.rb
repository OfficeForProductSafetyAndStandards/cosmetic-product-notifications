module NanomaterialHelper
  def ec_regulation_annex_details_for_nanomaterial_purposes(purposes)
    return "No annexes" if purposes.blank?

    annex_numbers = purposes.filter_map { |purpose| NanoMaterialPurposes.find(purpose)&.annex_number }

    if annex_numbers.empty?
      "No annexes"
    else
      "#{'Annex'.pluralize(annex_numbers.count)} #{to_sentence(annex_numbers, last_word_connector: ' and ')}"
    end
  end
end
