module ResponsiblePersons::Notifications
  class ExactConcentrationForm < Form
    include StripWhitespace

    attribute :name
    attribute :exact_concentration
    attribute :cas_number
    attribute :poisonous
    attribute :component

    validates :name, presence: true
    validate :unique_name
    validates :exact_concentration, presence: true
    validates_with CasNumberValidator

  private

    def unique_name
      return if name.blank?

      if ExactFormula.where(component_id: component).where("LOWER(inci_name) = ?", name.downcase).any?
        errors.add(:name, :taken)
      end
    end
  end
end
