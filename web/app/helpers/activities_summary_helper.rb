module ActivitiesSummaryHelper
  def build_subtitle activity
    "#{activity.subtitle_slug} by #{activity.source.show}, #{activity.created_at.strftime('%d %B %Y')}"
  end
end
