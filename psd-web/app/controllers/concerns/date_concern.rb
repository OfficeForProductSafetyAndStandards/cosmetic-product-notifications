module DateConcern
  extend ActiveSupport::Concern
  included do # rubocop:disable Metrics/BlockLength

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
      keys = date_keys
      keys.each do |key|
        self.class_eval do
          attr_accessor "#{key.to_s}_day".to_sym, :integer
          attr_accessor "#{key.to_s}_month".to_sym, :integer
          attr_accessor ("#{key.to_s}_year".to_sym), :integer
        end

        date = self[key]
        if date.present? && get_date_components(key).all?(&:blank?)
          self.send("#{key.to_s}_day=", date.day)
          self.send("#{key.to_s}_month=", date.month)
          self.send("#{key.to_s}_year=", date.year)
        else
          update_from_components(key)
        end
      end
    end

    before_validation do
      date_keys.each do |key|
        if get_date_components(key).any?(&:present?)
          self[key] = nil
        end
        update_from_components(key)
      end
    end
  end

  def date_keys
    # Can be overwritten in any class using the helper
    [:date]
  end

  def set_day(key, value)
    self.send("#{key.to_s}_day=", value)
  end

  def set_month(key, value)
    self.send("#{key.to_s}_month=", value)
  end

  def set_year(key, value)
    self.send("#{key.to_s}_year=", value)
  end

  def get_day(key)
    self.send("#{key.to_s}_day".to_sym)
  end

  def get_month(key)
    self.send("#{key.to_s}_month".to_sym)
  end

  def get_year(key)
    self.send("#{key.to_s}_year".to_sym)
  end

  def get_date_components(key)
    [get_year(key), get_month(key), get_day(key)]
  end

  def get_date(key)
    date_components = get_date_components(key).map(&:to_i)
    Date.valid_civil?(*date_components) ? Date.civil(*date_components): nil
  end

  def update_dates_from_params(params)
    # expects to receive the part of params relevant to the object it's on
    return if params.blank?

    date_keys.each do |key|
      next if params[key].blank?
      data_from_params = params.require(key).permit(:day, :month, :year)
      set_day(key, data_from_params[:day])
      set_month(key, data_from_params[:month])
      set_year(key, data_from_params[:year])
    end
  end
private

  def update_from_components(key)
    unless get_date_components(key).any?(&:blank?)
      date_component_values = get_date_components(key).map(&:to_i)
      if Date.valid_civil?(*date_component_values)
        # This sets it if it makes sense. Validation then can compare the presence of
        # date and its components to know if the date parsed correctly
        self[key] = Date.civil(*date_component_values)
      else
        self[key] = nil
      end
    end
  end

  def date_from_components
    date_keys.each do |key|
      missing_date_components = {}
      missing_date_components["#{key.to_s}_day".to_sym] = get_day(key)
      missing_date_components["#{key.to_s}_month".to_sym] = get_month(key)
      missing_date_components["#{key.to_s}_year".to_sym] = get_year(key)
      missing_date_components = missing_date_components.select { |_, value| value.blank? }

      case missing_date_components.length
      when 3
        errors.add(key, :invalid)
      when (1..2) # Date has some components entered, but not all
        missing_date_components.each do |missing_component, _|
          errors.add(key, :date_missing_component)
          errors.add(missing_component, "")
        end
      when 0
        if self[key].blank?
          errors.add(key, :invalid)
          errors.add("#{key.to_s}_day".to_sym, "")
          errors.add("#{key.to_s}_month".to_sym, "")
          errors.add("#{key.to_s}_year".to_sym, "")
        end
      end
    end
  end

end
