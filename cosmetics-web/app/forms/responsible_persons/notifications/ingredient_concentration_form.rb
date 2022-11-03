module ResponsiblePersons::Notifications
  class IngredientConcentrationForm < Form
    EXACT = "exact".freeze
    RANGE = "range".freeze

    include StripWhitespace

    attribute :name, :string
    attribute :exact_concentration
    attribute :range_concentration, :string
    attribute :cas_number, :string
    attribute :poisonous, :boolean
    attribute :component
    attribute :updating_ingredient
    attribute :ingredient_number, :integer
    attribute :type, :string

    validates :component, presence: true
    validates :type, inclusion: { in: [EXACT, RANGE] }
    validates :poisonous, inclusion: { in: [true, false] }, if: :range?
    validates :name, presence: true, ingredient_name_format: { message: :invalid }
    validate :unique_name
    validates :exact_concentration,
              presence: true,
              numericality: { allow_blank: true, greater_than: 0, less_than_or_equal_to: 100 },
              if: :exact?
    validates :range_concentration,
              presence: true,
              if: -> { range? && poisonous == false }
    validates_with CasNumberValidator

    def initialize(params = {})
      super(params)
      return if type.blank?

      # Clearing data coming from user form submission.
      # If user fills concentration for an ingredient type, and then changes the type, this code clears the
      # concentration for the previous type. So only the correct one is kept on form/saved in DB.
      # Also enforces "exact" type for a "Range poisonous ingredient", that is provided as an exact concentration.
      if type == RANGE && !poisonous
        self.exact_concentration = nil
      else
        self.type = EXACT
        self.range_concentration = nil
      end
    end

    def range?
      type == RANGE
    end

    def exact?
      type == EXACT
    end

    def save
      return false unless valid?

      if updating_ingredient
        updating_ingredient.update(ingredient_attributes)
      else
        component.ingredients.create(ingredient_attributes)
      end
    end

  private

    def ingredient_attributes
      {
        inci_name: name,
        exact_concentration:,
        range_concentration:,
        cas_number:,
        poisonous: poisonous.presence || false,
      }
    end

    def unique_name
      return if name.blank? || component.blank?

      if Ingredient.where(component_id: component, inci_name: name).where.not(id: updating_ingredient).any?
        errors.add(:name, :taken, entity: component.notification.is_multicomponent? ? "item" : "product")
      end
    end
  end
end
