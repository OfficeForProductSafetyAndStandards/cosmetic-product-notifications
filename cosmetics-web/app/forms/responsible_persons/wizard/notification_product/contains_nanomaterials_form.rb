module ResponsiblePersons
  module Wizard
    module NotificationProduct
      class ContainsNanomaterialsForm < Form
        include StripWhitespace

        attribute :contains_nanomaterials
        attribute :nanomaterials_count

        validates :contains_nanomaterials, inclusion: { in: %w[yes no] }
        validates :nanomaterials_count,
                  numericality: { greater_than: 0, less_than_or_equal_to: 10 },
                  if: -> { contains_nanomaterials == "yes" }

        def contains_nanomaterials?
          contains_nanomaterials == "yes"
        end
      end
    end
  end
end
