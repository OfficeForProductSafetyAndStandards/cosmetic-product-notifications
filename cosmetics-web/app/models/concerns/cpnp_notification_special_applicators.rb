module CpnpNotificationSpecialApplicators
  def get_special_applicator(id)
    SPECIAL_APPLICATOR_ID[id]
  end

  SPECIAL_APPLICATOR_ID = {
      100001 => :wipe_sponge_patch_pad,
      100002 => :encapsulated_products,
      100003 => :pressurised_spray_container,
      100004 => :pressurised_container_non_spray_product,
      99998 => :other_special_applicator
  }.freeze
end
