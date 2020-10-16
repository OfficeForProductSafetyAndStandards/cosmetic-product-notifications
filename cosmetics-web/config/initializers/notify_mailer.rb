ActionMailer::Base.add_delivery_method :submit_govuk_notify, GovukNotifyRails::Delivery, api_key: ENV["NOTIFY_API_KEY"]
ActionMailer::Base.add_delivery_method :search_govuk_notify, GovukNotifyRails::Delivery, api_key: ENV["SEARCH_NOTIFY_API_KEY"]
