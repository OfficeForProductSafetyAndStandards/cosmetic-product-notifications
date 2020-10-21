# Rails cleverly surrounds fields with validation errors with a div that changes how they look
# Sadly it is not Digital Service Standard compliant, so we prevent it here
Rails.application.config.action_view.field_error_proc = proc do |html_tag, _|
  html_tag
end

Rails.application.config.action_view.form_with_generates_ids = true

ActionView::Base.include GovukDesignSystem::ComponentsHelper
ActionView::Base.include GovukDesignSystem::DetailsHelper
ActionView::Base.include GovukDesignSystem::WarningTextHelper
ActionView::Base.include GovukDesignSystem::BackLinkHelper
ActionView::Base.include GovukDesignSystem::SummaryListHelper
ActionView::Base.include GovukDesignSystem::FileUploadHelper
ActionView::Base.include GovukDesignSystem::ErrorMessageHelper
ActionView::Base.include GovukDesignSystem::LabelHelper
ActionView::Base.include GovukDesignSystem::HintHelper
ActionView::Base.include GovukDesignSystem::PhaseBannerHelper
ActionView::Base.include GovukDesignSystem::TagHelper
ActionView::Base.include GovukDesignSystem::ButtonHelper
ActionView::Base.include GovukDesignSystem::ErrorSummaryHelper
