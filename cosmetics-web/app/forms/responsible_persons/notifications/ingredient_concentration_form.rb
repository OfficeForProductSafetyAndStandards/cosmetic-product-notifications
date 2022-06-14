module ResponsiblePersons::Notifications
  class IngredientConcentrationForm < Form
    EXACT = "exact".freeze
    RANGE = "range".freeze

    include StripWhitespace

    attribute :name, :string
    attribute :exact_concentration, :float
    attribute :range_concentration, :string
    attribute :cas_number, :string
    attribute :poisonous, :boolean
    attribute :component
    attribute :type, :string

    validates :component, presence: true
    validates :type, inclusion: { in: [EXACT, RANGE] }
    validates :name, presence: true
    validate :unique_name
    validates :exact_concentration,
              presence: true,
              numericality: { allow_blank: true, greater_than: 0 },
              if: :exact?
    validates :range_concentration,
              presence: true,
              if: :range?
    validates_with CasNumberValidator

    def initialize(params = {})
      super(params)
      self.type = EXACT if type == RANGE && poisonous
    end

    def range?
      type == RANGE
    end

    def exact?
      type == EXACT
    end

    def save
      return false unless valid?

      case type
      when EXACT then create_exact_ingredient
      when RANGE then create_range_ingredient
      end
    end

  private

    def create_exact_ingredient
      component.exact_formulas.create(
        inci_name: name,
        quantity: exact_concentration,
        cas_number: cas_number,
        poisonous: poisonous,
      )
    end

    def create_range_ingredient
      component.range_formulas.create(
        inci_name: name,
        range: range_concentration,
        cas_number: cas_number,
      )
    end

    def unique_name
      return if name.blank? || component.blank?

      if ingredient_exists_in?(ExactFormula) || ingredient_exists_in?(RangeFormula)
        errors.add(:name, :taken, entity: component.notification.is_multicomponent? ? "item" : "product")
      end
    end

    def ingredient_exists_in?(ingredient_class)
      ingredient_class.where(component_id: component).where("LOWER(inci_name) = ?", name.downcase).any?
    end
  end
end
