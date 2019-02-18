module DateConcern
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    attribute :day, :integer
    attribute :month, :integer
    attribute :year, :integer

    validate :date_from_components

    # The current implementation is focused on reflecting changes based on the component values changing in the form
    # This has a side effect of overriding values provided with the setter (using say `record.date = foo`)
    # The `clear_date` and `set_date` are sensible workarounds, but could be changed into a dynamic setter down the line
    def clear_date
      self.day, self.month, self.year, self[@date_key] = nil
    end

    def set_date(new_date)
      self.day = new_date.day
      self.month = new_date.month
      self.year = new_date.year
      self[@date_key] = new_date
    end

    after_initialize do
      @date_key = get_date_key

      date = self[@date_key]
      if date.present? && date_components.all?(&:blank?)
        self.day = date.day
        self.month = date.month
        self.year = date.year
      else
        update_from_components
      end
    end

    before_validation do
      if date_components.any?(&:present?)
        self[@date_key] = nil
      end

      update_from_components
    end
  end

  def get_date_key
    # Can be overwritten in any class using the helper
    :date
  end

private

  def update_from_components
    unless date_components.any?(&:blank?)
      date_component_values = date_components.map(&:to_i)
      if Date.valid_civil?(*date_component_values)
        # This sets it if it makes sense. Validation then can compare the presence of
        # date and its components to know if the date parsed correctly
        self[@date_key] = Date.civil(*date_component_values)
      end
    end
  end

  def date_from_components
    missing_date_components = {
        day: day, month: month, year: year
    }.select { |_, value| value.blank? }
    case missing_date_components.length
    when (1..2) # Date has some components entered, but not all
      missing_date_components.each do |missing_component, _|
        errors.add(@date_key, :date_missing_component)
        errors.add(missing_component, "")
      end
    when 0
      if self[@date_key].blank?
        errors.add(@date_key, :invalid)
        errors.add(:day, "")
        errors.add(:month, "")
        errors.add(:year, "")
      end
    end
  end

  def date_components
    [year, month, day]
  end
end
