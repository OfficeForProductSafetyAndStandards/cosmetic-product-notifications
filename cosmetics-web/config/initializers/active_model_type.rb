require_dependency "active_model/types/govuk_date"
ActiveModel::Type.register(:govuk_date, ActiveModel::Types::GovUKDate)
