module NanomaterialHelper
  def ec_regulation_annex_details_for_nanomaterial_purposes(purposes)
    annex_numbers = purposes.filter_map { |purpose| NanoElementPurposes.find(purpose)&.annex_number }
    "#{'Annex'.pluralize(annex_numbers.count)} #{to_sentence(annex_numbers, last_word_connector: ' and ')}"
  end
end
