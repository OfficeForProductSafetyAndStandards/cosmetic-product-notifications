class ChangeExposureRouteToArray < ActiveRecord::Migration[5.2]
  def up
    add_column :nano_materials, :exposure_routes, :string, array: true

    NanoMaterial.all.each do |nano_material|
      nano_material.exposure_routes = Array(nano_material.exposure_route) if nano_material.exposure_route.present?
      nano_material.save
    end

    safety_assured { remove_column :nano_materials, :exposure_route }
  end

  def down
    add_column :nano_materials, :exposure_route, :string

    NanoMaterial.all.each do |nano_material|
      nano_material.exposure_route = nano_material.exposure_routes&.first
      nano_material.save
    end

    safety_assured { remove_column :nano_materials, :exposure_routes }
  end
end
