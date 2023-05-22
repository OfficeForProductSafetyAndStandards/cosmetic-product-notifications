module FormulationHelper
  def formulations_types_label
    {
      predefined: { text: "Choose a predefined frame formulation" },
      exact: { text: "Enter ingredients and their exact concentration manually" },
      range: { text: "Enter ingredients and their concentration range manually" },
      separator: { text: "or" },
      exact_csv: { text: "Upload a CSV file for ingredients and their exact concentration" },
      range_csv: { text: "Upload a CSV file for ingredients and their concentration range" },
    }
  end
end
