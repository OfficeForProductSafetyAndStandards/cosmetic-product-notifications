class AddQuestionAsPartOfCase < ActiveRecord::Migration[5.2]
  def change
    add_column :investigations, :object_type, :string
  end
end
