module FormulationHelper
  def formulations_types_label
    {
      predefined: { text: "Choose a predefined frame formulation" },
      exact: { text: "Enter ingredients and their exact concentration manually" },
      exact_csv: { text: "Provide ingredients and their exact concentration using a CSV file", classes: "govuk-!-font-size-16", wrapper_classes: "govuk-radios--small govuk-!-margin-left-8" },
      range: { text: "Enter ingredients and their concentration range manually" },
    }
  end
end
