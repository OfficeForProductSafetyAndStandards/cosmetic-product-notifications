class AddAssigneeToInvestigations < ActiveRecord::Migration[5.2]
  def change
    add_reference :investigations, :assignee, type: :uuid
    add_foreign_key :investigations, :users, column: :assignee_id
  end
end
