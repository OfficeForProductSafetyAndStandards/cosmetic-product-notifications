class AddExposureConditionAndExposureRoutesToComponents < ActiveRecord::Migration[6.1]
  def change
    add_column :components, :exposure_condition, :string
    add_column :components, :exposure_routes, :string, array: true
  end
end
