module DateConcern
  extend ActiveSupport::Concern

  included do
    attribute :day, :integer
    attribute :month, :integer
    attribute :year, :integer

    validate :date_from_components

    after_initialize do
      @date_key = get_date_key
      date_component_strings = [year, month, day]

      if date_component_strings.any?(&:present?)
        self[@date_key] = nil
      end

      unless date_component_strings.any?(&:blank?)
        date_components = date_component_strings.map(&:to_i)
        if Date.valid_civil?(*date_components)
          # This sets it if it makes sense. Validation then can compare the presence of
          # date and its components to know if the date parsed correctly
          self[@date_key] = Date.civil(*date_components)
        end
      end
    end
  end

  def get_date_key
    # Can be overwritten in any class using the helper
    :date
  end

  def date_from_components
    missing_date_components = {
      day: day, month: month, year: year
    }.select { |_, value| value.blank? }
    case missing_date_components.length
    when (1..2) # Date has some components entered, but not all
      missing_date_components.each do |missing_component, _|
        errors.add(@date_key, "must specify a day, month and year")
        errors.add(missing_component, "can't be blank")
      end
    when 0
      if self[@date_key].blank?
        errors.add(@date_key, "must be a valid date")
        errors.add(:day)
        errors.add(:month)
        errors.add(:year)
      end
    end
  end
end
