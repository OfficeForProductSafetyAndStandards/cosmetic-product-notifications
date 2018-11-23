module LegislationHelper
  def relevant_legislation
    Rails.application.config.legislation_constants["legislation"]&.sort
  end
end
