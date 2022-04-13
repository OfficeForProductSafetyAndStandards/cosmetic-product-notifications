module ResponsiblePersons::Notifications::Product
  class SingleOrMultiComponentForm < Form
    SINGLE = "single".freeze
    MULTI = "multiple".freeze

    include StripWhitespace

    attribute :single_or_multi_component
    attribute :components_count

    validates :single_or_multi_component, inclusion: { in: [SINGLE, MULTI] }
    validates :components_count,
              numericality: { greater_than: 1, less_than_or_equal_to: 10, only_integer: true },
              if: -> { multi_component? }

    def single_component?
      single_or_multi_component == SINGLE
    end

    def multi_component?
      single_or_multi_component == MULTI
    end
  end
end
