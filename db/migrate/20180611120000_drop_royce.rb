# frozen_string_literal: true

class DropRoyce < ActiveRecord::Migration[4.2]

  def change

    drop_table :royce_connector
    drop_table :royce_role

  end
end
