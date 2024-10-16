class AddOpssImtToUserRoles < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      ActiveRecord::Base.connection.execute <<-SQL
        ALTER TYPE user_roles ADD VALUE 'opss_imt'
      SQL
    end
  end
end
