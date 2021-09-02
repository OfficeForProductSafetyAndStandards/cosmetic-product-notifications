module ResponsiblePersons
  class SelectionForm < Form
    NEW = "new".freeze

    attribute :selection
    attribute :previous
    attribute :available

    validate :selection_presence

    def radio_items
      @radio_items ||=
        available.sort_by(&:name).map { |rp| { text: rp.name, value: rp.id } }.tap do |items|
          items << { divider: "or" } if items.any?
          items << { text: "Add a new Responsible Person", value: NEW }
        end
    end

    # Removes the currently selected RP from the selection options
    def available
      @available ||= super.excluding(previous) # "super" access the original attribute value
    end

    def add_new?
      selection == NEW
    end

  private

    def selection_presence
      return if selection.present?

      errors.add(:selection, available.any? ? :blank_with_rp_list : :blank_without_rp_list)
    end
  end
end
