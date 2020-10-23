module CpnpNotificationSpecialApplicators
  def get_special_applicator(id)
    SPECIAL_APPLICATOR_ID[id]
  end

  SPECIAL_APPLICATOR_ID = {
    100_001 => :wipe_sponge_patch_pad,
    100_002 => :encapsulated_products,
    100_003 => :pressurised_spray_container,
    100_004 => :pressurised_container_non_spray_product,
    99_998 => :other_special_applicator,
  }.freeze
end
