class AddPhToComponents < ActiveRecord::Migration[5.2]
  def up
    add_column :components, :ph, :text
  end

  def down
    remove_column :components, :ph
  end
end
