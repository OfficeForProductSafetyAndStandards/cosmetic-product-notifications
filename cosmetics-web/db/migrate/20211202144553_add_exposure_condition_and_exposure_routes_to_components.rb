class AddExposureConditionAndExposureRoutesToComponents < ActiveRecord::Migration[6.1]
  def change
    # rubocop:disable RSpec/BulkChangeTable
    add_column :components, :exposure_condition, :string
    add_column :components, :exposure_routes, :string, array: true
    # rubocop:enable RSpec/BulkChangeTable
  end
end
