class SetDefaultFields < ActiveRecord::Migration[5.2]
  def up
    Investigation.where(is_closed: nil).update_all(is_closed: false)
    change_column :investigations, :is_closed, :boolean, default: false
  end

  def down
    change_column :investigations, :is_closed, :boolean, default: nil
  end
end
