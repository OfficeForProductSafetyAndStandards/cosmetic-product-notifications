module Investigations::VisibilityHelper
  def visible_investigations(item)
    business_related_ids = item.investigations.map(&:id)
    case_assigned_ids = Investigation.where(assignee_id: user_group_ids).map(&:id)
    case_sourced_ids = Investigation.joins(:source).merge(Source.where(user_id: user_group_ids)).map(&:id)
    Investigation.where(id: (case_assigned_ids + case_sourced_ids) & business_related_ids)
  end
end
