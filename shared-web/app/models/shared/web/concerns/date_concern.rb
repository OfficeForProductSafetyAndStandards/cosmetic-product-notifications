# rubocop:disable Metrics/BlockLength
module Shared
  module Web
    module Concerns
      module DateConcern
        extend ActiveSupport::Concern
        included do
          validate :date_from_components

          after_initialize do
            keys = date_keys
            keys.each do |key|
              self.class_eval do
                attr_accessor "#{key}_day".to_sym, :integer
                attr_accessor "#{key}_month".to_sym, :integer
                attr_accessor "#{key}_year".to_sym, :integer
              end

              date = self[key]
              if date.present? && get_date_components(key).all?(&:blank?)
                set_day(key, date.day)
                set_month(key, date.month)
                set_year(key, date.year)
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

        def update_dates_from_params(params)
          # expects to receive the part of params relevant to the object it's on
          return if params.blank?

          date_keys.each do |key|
            next if params[key].blank?

            data_from_params = params.require(key).permit(:day, :month, :year)
            set_day(key, data_from_params[:day])
            set_month(key, data_from_params[:month])
            set_year(key, data_from_params[:year])
            update_from_components(key)
          end
        end

        # The current implementation is focused on reflecting changes based on the component values changing in the form
        # This has a side effect of overriding values provided with the setter (using say `record.date = foo`)
        # The `clear_date` and `set_date` are sensible workarounds, but could be changed into a dynamic setter down the line
        def clear_date(key: date_keys.first)
          set_day(key, nil)
          set_month(key, nil)
          set_year(key, nil)
          self[key] = nil
        end

        def set_date(new_date, key: date_keys.first)
          set_day(key, new_date.day)
          set_month(key, new_date.month)
          set_year(key, new_date.year)
          self[key] = new_date
        end

      private

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
          self.send("#{key}_day".to_sym)
        end

        def get_month(key)
          self.send("#{key}_month".to_sym)
        end

        def get_year(key)
          self.send("#{key}_year".to_sym)
        end

        def update_from_components(key)
          return if get_date_components(key).any?(&:blank?)

          date_component_values = get_date_components(key).map(&:to_i)
          if Date.valid_civil?(*date_component_values)
            # This sets it if it makes sense. Validation then can compare the presence of
            # date and its components to know if the date parsed correctly
            self[key] = Date.civil(*date_component_values)
          end
        end

        def date_from_components
          date_keys.each do |key|
            missing_date_components = {}
            missing_date_components["#{key}_day".to_sym] = get_day(key)
            missing_date_components["#{key}_month".to_sym] = get_month(key)
            missing_date_components["#{key}_year".to_sym] = get_year(key)
            missing_date_components = missing_date_components.select { |_, value| value.blank? }

            case missing_date_components.length
            when 3
              errors.add(key, :date_required)
            when (1..2) # Date has some components entered, but not all
              missing_date_components.each do |missing_component, _|
                errors.add(key, :date_missing_component)
                errors.add(missing_component, "")
              end
            when 0
              if self[key].blank?
                errors.add(key, :invalid)
                errors.add("#{key}_day".to_sym, "")
                errors.add("#{key}_month".to_sym, "")
                errors.add("#{key}_year".to_sym, "")
              end
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
