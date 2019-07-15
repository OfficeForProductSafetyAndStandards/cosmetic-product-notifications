class AddOtherSpecialApplicatorToComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :components, :other_special_applicator, :string
  end
end
