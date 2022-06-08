module ResponsiblePersons::Notifications
  class ExactConcentrationForm < Form
    include StripWhitespace

    attribute :name, :string
    attribute :exact_concentration, :float
    attribute :cas_number, :string
    attribute :poisonous, :boolean
    attribute :component

    validates :name, presence: true
    validate :unique_name
    validates :exact_concentration, presence: true
    validates_with CasNumberValidator

    def save
      return false unless component.present? && valid?

      component.exact_formulas.create(
        inci_name: name,
        quantity: exact_concentration,
        cas_number: cas_number,
        poisonous: poisonous,
      )
    end

  private

    def unique_name
      return if name.blank? || component.blank?

      if ExactFormula.where(component_id: component).where("LOWER(inci_name) = ?", name.downcase).any?
        errors.add(:name, :taken, entity: component.notification.is_multicomponent? ? "item" : "product")
      end
    end
  end
end
