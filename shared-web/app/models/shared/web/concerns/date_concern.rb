module Shared
  module Web
    module Concerns
      module DateConcern
        extend ActiveSupport::Concern
        included do
          validate :date_from_components

          def self.add_date_key(key, required)
            @date_keys ||= []
            @date_keys << [key, required] unless @date_keys.include? [key, required]
          end

          def self.get_date_keys
            @date_keys
          end

          def self.date_attribute(key, required: true)
            self.class_eval do
              attribute "#{key}_day".to_sym, :integer
              attribute "#{key}_month".to_sym, :integer
              attribute "#{key}_year".to_sym, :integer
            end

            after_initialize do
              initialize_date(key, required)
            end
          end
        end

        def set_dates_from_params(params)
          # expects to receive the part of params relevant to the object it's on
          return if params.blank?

          self.class.get_date_keys.each do |key, required|
            next if params[key].blank?

            data_from_params = params.require(key).permit(:day, :month, :year)
            set_day(key, data_from_params[:day])
            set_month(key, data_from_params[:month])
            set_year(key, data_from_params[:year])
            update_from_components(key, required)
          end
        end

        # The current implementation is focused on reflecting changes based on the component values changing in the form
        # This has a side effect of overriding values provided with the setter (using say `record.date = foo`)
        # The `clear_date` and `set_date` are sensible workarounds, but could be changed into a dynamic setter down the line
        def clear_date(key: default_key)
          set_day(key, nil)
          set_month(key, nil)
          set_year(key, nil)
          self[key] = nil
        end

        def set_date(new_date, key: default_key)
          set_day(key, new_date.day)
          set_month(key, new_date.month)
          set_year(key, new_date.year)
          self[key] = new_date
        end

      private

        def default_key
          self.class.get_date_keys.first[0]
        end

        def get_date_components(key)
          [get_year(key), get_month(key), get_day(key)]
        end

        def set_day(key, value)
          self.send("#{key}_day=", value)
        end

        def set_month(key, value)
          self.send("#{key}_month=", value)
        end

        def set_year(key, value)
          self.send("#{key}_year=", value)
        end

        def get_day(key)
          self.send(day_symbol(key))
        end

        def get_month(key)
          self.send(month_symbol(key))
        end

        def get_year(key)
          self.send(year_symbol(key))
        end

        def day_symbol(key)
          "#{key}_day".to_sym
        end

        def month_symbol(key)
          "#{key}_month".to_sym
        end

        def year_symbol(key)
          "#{key}_year".to_sym
        end

        def initialize_date(key, required)
          self.class.add_date_key(key, required)
          date = self[key]
          if date.present? && get_date_components(key).all?(&:blank?)
            set_day(key, date.day)
            set_month(key, date.month)
            set_year(key, date.year)
          else
            update_from_components(key, required)
          end
        end

        def update_from_components(key, required)
          self[key] = nil if get_date_components(key).all?(&:blank?) && !required
          return if get_date_components(key).any?(&:blank?)

          date_component_values = get_date_components(key).map(&:to_i)
          if Date.valid_civil?(*date_component_values)
            # This sets it if it makes sense. Validation then can compare the presence of
            # date and its components to know if the date parsed correctly
            self[key] = Date.civil(*date_component_values)
          end
        end

        def date_from_components
          self.class.get_date_keys.each do |key, required|
            prepare_for_validation(key, required)
            missing_date_components = get_missing_date_components(key)

            case missing_date_components.length
            when 3
              errors.add(key, :blank) if required
            when (1..2) # Date has some components entered, but not all
              errors.add(key, :date_missing_component, missing_components: missing_components_text(key))
              missing_date_components.each do |missing_component, _|
                errors.add(missing_component, "")
              end
            when 0
              if self[key].blank?
                errors.add(key, :invalid)
                errors.add(day_symbol(key), "")
                errors.add(month_symbol(key), "")
                errors.add(year_symbol(key), "")
              end
            end
          end
        end

        def prepare_for_validation(key, required)
          if get_date_components(key).any?(&:present?)
            self[key] = nil
          end
          update_from_components(key, required)
        end

        def get_missing_date_components(key)
          date_components = {}
          date_components[day_symbol(key)] = get_day(key)
          date_components[month_symbol(key)] = get_month(key)
          date_components[year_symbol(key)] = get_year(key)
          date_components.select { |_, value| value.blank? }
        end

        def missing_components_text(key)
          missing_elements = []
          missing_elements << "day" if get_day(key).blank?
          missing_elements << "month" if get_month(key).blank?
          missing_elements << "year" if get_year(key).blank?
          missing_elements.join(" and ")
        end
      end
    end
  end
end
