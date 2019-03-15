module CpnpNotificationExposures
  def get_exposure_route(id)
    EXPOSURE_ROUTE_ID[id]
  end

  def get_exposure_condition(id)
    EXPOSURE_CONDITION_ID[id]
  end

  EXPOSURE_ROUTE_ID = {
      3 => :dermal,
      4 => :oral,
      5 => :inhalation
  }.freeze

  EXPOSURE_CONDITION_ID = {
      1 => :rinse_off,
      2 => :leave_on
  }.freeze
end
