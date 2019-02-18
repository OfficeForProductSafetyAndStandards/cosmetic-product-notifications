class MakePrettyIdWorkWithOldCases < ActiveRecord::Migration[5.2]
  def change
    Investigation.in_batches.each_record(&:add_pretty_id)
  end
end
