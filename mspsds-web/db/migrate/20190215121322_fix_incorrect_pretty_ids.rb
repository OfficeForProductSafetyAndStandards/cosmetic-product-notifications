class FixIncorrectPrettyIds < ActiveRecord::Migration[5.2]
  def change
    Investigation.all.each do |investigation|
      investigation.add_pretty_id
    end
  end
end
