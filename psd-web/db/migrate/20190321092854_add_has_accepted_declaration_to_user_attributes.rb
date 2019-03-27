class AddHasAcceptedDeclarationToUserAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :user_attributes, :has_accepted_declaration, :boolean
  end
end
