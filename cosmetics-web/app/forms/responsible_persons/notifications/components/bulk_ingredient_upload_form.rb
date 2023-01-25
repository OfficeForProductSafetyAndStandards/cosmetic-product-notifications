module ResponsiblePersons::Notifications::Components
  class BulkIngredientUploadForm < Form
    attribute :file
    attribute :component

    def create_ingredients
      # * no file uploaded
      # * CSV::MalformedCSVError
      return unless valid?

      # now, the creation of ingredients
      # * errors in the CSV itself
    end
  end
end
