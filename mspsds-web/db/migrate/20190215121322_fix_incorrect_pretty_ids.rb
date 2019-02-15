class FixIncorrectPrettyIds < ActiveRecord::Migration[5.2]
  def change
    Investigation.all.each(&:add_pretty_id)
  end
end
