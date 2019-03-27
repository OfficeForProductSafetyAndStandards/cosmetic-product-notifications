class FixIncorrectPrettyIds < ActiveRecord::Migration[5.2]
  def change
    Investigation.in_batches.each_record do |record|
      record.add_pretty_id
      record.save
    end
  end
end
