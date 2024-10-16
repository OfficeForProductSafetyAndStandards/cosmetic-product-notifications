class AddOpssScienceToUserRoles < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      ActiveRecord::Base.connection.execute <<-SQL
        ALTER TYPE user_roles ADD VALUE 'opss_science'
      SQL
    end
  end
end
