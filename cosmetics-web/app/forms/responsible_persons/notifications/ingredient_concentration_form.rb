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
    attribute :updating_ingredient
    attribute :ingredient_number, :integer
    attribute :type, :string

    validates :component, presence: true
    validates :type, inclusion: { in: [EXACT, RANGE] }
    validates :poisonous, inclusion: { in: [true, false] }, if: :range?
    validates :name, presence: true
    validate :unique_name
    validates :exact_concentration,
              presence: true,
              numericality: { allow_blank: true, greater_than: 0 },
              if: :exact?
    validates :range_concentration,
              presence: true,
              if: -> { range? && poisonous == false }
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
      when EXACT then save_exact_ingredient
      when RANGE then save_range_ingredient
      end
    end

  private

    def save_exact_ingredient
      case updating_ingredient
      when nil then create_exact_ingredient
      when ExactFormula then update_exact_ingredient
      when RangeFormula then update_range_to_exact_ingredient
      end
    end

    def save_range_ingredient
      case updating_ingredient
      when nil then create_range_ingredient
      when ExactFormula then update_exact_to_range_ingredient
      when RangeFormula then update_range_ingredient
      end
    end

    def create_exact_ingredient(created_at: Time.zone.now)
      component.exact_formulas.create(
        inci_name: name,
        quantity: exact_concentration,
        cas_number: cas_number,
        poisonous: poisonous,
        created_at: created_at,
      )
    end

    def create_range_ingredient(created_at: Time.zone.now)
      component.range_formulas.create(
        inci_name: name,
        range: range_concentration,
        cas_number: cas_number,
        created_at: created_at,
      )
    end

    def update_exact_ingredient
      updating_ingredient.update(
        inci_name: name,
        quantity: exact_concentration,
        cas_number: cas_number,
        poisonous: poisonous,
      )
    end

    def update_range_ingredient
      updating_ingredient.update(
        inci_name: name,
        range: range_concentration,
        cas_number: cas_number,
      )
    end

    def update_range_to_exact_ingredient
      ActiveRecord::Base.transaction do
        new_ingredient = create_exact_ingredient(created_at: updating_ingredient.created_at)
        updating_ingredient.destroy
        new_ingredient
      end
    end

    def update_exact_to_range_ingredient
      ActiveRecord::Base.transaction do
        new_ingredient = create_range_ingredient(created_at: updating_ingredient.created_at)
        updating_ingredient.destroy
        new_ingredient
      end
    end

    def unique_name
      return if name.blank? || component.blank?
      return if updating_ingredient&.inci_name&.casecmp(name)&.zero?

      if ingredient_exists_in?(ExactFormula) || ingredient_exists_in?(RangeFormula)
        errors.add(:name, :taken, entity: component.notification.is_multicomponent? ? "item" : "product")
      end
    end

    def ingredient_exists_in?(ingredient_class)
      ingredient_class.where(component_id: component).where("LOWER(inci_name) = ?", name.downcase).any?
    end
  end
end
