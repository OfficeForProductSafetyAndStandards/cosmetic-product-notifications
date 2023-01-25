module ResponsiblePersons::Notifications::Components
  class FormulationTypeForm < Form
    FRAME_FORMULATION               = "frame_formulation".freeze
    EXACT_FORMULATION               = "exact_formulation".freeze
    EXACT_FORMULATION_CSV           = "exact_formulation_csv".freeze
    CONCENTRATION_RANGE_FORMULATION = "concentration_range_formulation".freeze

    attribute :frame_formulation
    attribute :exact_formulation
    attribute :exact_formulation_csv
    attribute :concentration_range_formulation
  end
end
