class PopulateAssigneeAndDescription < ActiveRecord::Migration[5.2]
  def change
    Investigation.all.each do |i|
      i.description = i.description || i.reason_created
      i.assignee = i.assignee || i.source.user
      i.save
    end
  end
end
