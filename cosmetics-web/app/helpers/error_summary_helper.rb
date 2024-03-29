module ErrorSummaryHelper
  # Generates an error summary for a model, if there are any
  # errors present.
  #
  # The first_values parameters can be used to specify multi-answer
  # attributes (eg radio buttons and checkboxes) and the value
  # of their first answer. This is used in the link for the error message,
  # so that that clicking the error focuses the first answer.
  def error_summary_for(model, first_values: {}, all_errors: false)
    if model.errors.any?

      error_list = []

      model.errors.messages.each do |attribute, messages|
        next if messages.empty?

        href = "##{model.model_name.singular}_#{attribute}"

        if first_values[attribute]
          href += "_#{first_values[attribute]}"
        end

        if all_errors
          messages.each do |message|
            error_list << { text: message, href: }
          end
        else
          error_list << { text: messages[0], href: }
        end
      end

      govukErrorSummary(titleText: "There is a problem", errorList: error_list)
    end
  end
end
