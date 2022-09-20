class RemoveComponentIdFromNanoMaterials < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :nano_materials, :component_id, :bigint
    end
  end
end
