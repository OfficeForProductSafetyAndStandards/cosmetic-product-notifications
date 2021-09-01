module ResponsiblePersons
  class SelectionForm < Form
    attribute :selection
    attribute :previous
    attribute :available

    validate :selection_presence

    def radio_items
      @radio_items ||=
        available.sort_by(&:name).map { |rp| { text: rp.name, value: rp.id } }.tap do |items|
          items << { divider: "or" } if items.any?
          items << { text: "Add a new Responsible Person", value: :new }
        end
    end

    # We remove the currently selected RP as a selection option
    def available
      @available ||= super.excluding(previous)
    end

  private

    def selection_presence
      return if selection.present?

      errors.add(:selection, available.any? ? :blank_with_rp_list : :blank_without_rp_list)
    end
  end
end
