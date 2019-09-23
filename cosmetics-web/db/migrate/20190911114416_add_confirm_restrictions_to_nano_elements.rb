class AddConfirmRestrictionsToNanoElements < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :nano_elements, :confirm_toxicology_notified, :string
    end
  end
end
