class AddUniqueIndexOnComponentNames < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_index :components, %i[name notification_id], unique: true
    end
  end
end
