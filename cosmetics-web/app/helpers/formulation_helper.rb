module FormulationHelper
  def formulations_types_label
    {
      predefined: { text: "Choose a predefined frame formulation", wrapper_classes: "govuk-!-margin-bottom-8" },
      exact: { text: "Enter ingredients and their exact concentration manually" },
      exact_csv: { text: "Provide ingredients and their exact concentration using a CSV file", classes: "govuk-!-font-size-16 opss-secondary-text", wrapper_classes: "govuk-radios--small govuk-!-margin-left-9 govuk-!-margin-bottom-4" },
      range: { text: "Enter ingredients and their exact concentration manually" },
    }
  end
end
