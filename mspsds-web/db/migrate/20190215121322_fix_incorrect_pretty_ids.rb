class FixIncorrectPrettyIds < ActiveRecord::Migration[5.2]
  def change
    Investigation.in_batches { |relation| relation.each(&:add_pretty_id) }
  end
end
