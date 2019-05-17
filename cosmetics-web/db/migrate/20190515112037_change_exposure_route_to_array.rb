class ChangeExposureRouteToArray < ActiveRecord::Migration[5.2]
  def change
    add_column :nano_materials, :exposure_routes, :string, array: true

    nano_materials = NanoMaterial.all
    nano_materials.each do |nano_material|
      nano_material.exposure_routes = nano_material.exposure_route&.split(" ")
      nano_material.save
    end

    safety_assured { remove_column :nano_materials, :exposure_route, :string }
  end
end
