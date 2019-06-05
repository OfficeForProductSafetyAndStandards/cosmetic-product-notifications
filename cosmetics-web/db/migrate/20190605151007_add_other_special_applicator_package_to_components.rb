class AddOtherSpecialApplicatorPackageToComponents < ActiveRecord::Migration[5.2]
  def change
    # safety_assured required to prevent warnings about adding a column with a
    # non null default rewriting the entire table
    safety_assured {
      add_column :components, :other_special_applicator_package, :string
    }
  end
end
