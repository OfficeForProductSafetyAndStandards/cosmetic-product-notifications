module SupportPortal
  module AccountAdministrationHelper
    def account_type(klass)
      case klass
      when "SubmitUser"
        "Submit account"
      when "SearchUser"
        "Search account"
      end
    end
  end
end
