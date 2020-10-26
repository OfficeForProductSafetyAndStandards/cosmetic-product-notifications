module CpnpNotificationUnits
  def get_unit(id)
    UNIT_ID[id]
  end

  UNIT_ID = {
    1 => :less_than_01_percent,
    2 => :greater_than_01_less_than_1_percent,
    3 => :greater_than_1_less_than_5_percent,
    4 => :greater_than_5_less_than_10_percent,
    5 => :greater_than_10_less_than_25_percent,
    6 => :greater_than_25_less_than_50_percent,
    7 => :greater_than_50_less_than_75_percent,
    8 => :greater_than_75_less_than_100_percent,
  }.freeze
end
