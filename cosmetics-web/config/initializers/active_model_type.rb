require_dependency "active_model/type/govuk_date"
ActiveModel::Type.register(:govuk_date, ActiveModel::Types::GovUkDate)
