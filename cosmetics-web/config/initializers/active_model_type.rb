require_dependency "active_model/type/govuk_date"
require_dependency "active_model/type/strict_float"
ActiveModel::Type.register(:govuk_date, ActiveModel::Types::GovUkDate)
ActiveModel::Type.register(:strict_float, ActiveModel::Type::StrictFloat)
