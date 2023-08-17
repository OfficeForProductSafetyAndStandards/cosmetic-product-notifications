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

    def role_type(role)
      {
        "opss_enforcement" => "OPSS Enforcement",
        "opss_science" => "OPSS Science",
        "opss_general" => "OPSS General",
        "opss_imt" => "OPSS Incident Management Team (IMT)",
        "trading_standards" => "Trading Standards",
        "poison_centre" => "National Poisons Information Service (NPIS)",
      }[role]
    end

    def role_radios
      [
        OpenStruct.new(id: "opss_enforcement", name: "OPSS Enforcement"),
        OpenStruct.new(id: "opss_science", name: "OPSS Science"),
        OpenStruct.new(id: "opss_general", name: "OPSS General"),
        OpenStruct.new(id: "opss_imt", name: "OPSS Incident Management Team (IMT)"),
        OpenStruct.new(id: "trading_standards", name: "Trading Standards"),
        OpenStruct.new(id: "poison_centre", name: "National Poisons Information Service (NPIS)"),
      ]
    end
  end
end
