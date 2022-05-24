module ResponsiblePersons::Notifications
  class ExactConcentrationForm < Form
    attribute :name
    attribute :exact_concentration
    attribute :cas_number
    attribute :poisonous

    validates :name, presence: true
    validates :exact_concentration, presence: true
    validates_with CasNumberValidator
  end
end
