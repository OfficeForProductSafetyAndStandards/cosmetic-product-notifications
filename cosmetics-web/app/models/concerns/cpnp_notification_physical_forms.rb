module CpnpNotificationPhysicalForms
  def get_physical_form(id)
    PHYSICAL_FORM_ID[id]
  end

  PHYSICAL_FORM_ID = {
      1 => :solid_or_pressed_powder,
      2 => :loose_powder,
      3 => :cream_or_paste,
      4 => :liquid,
      5 => :foam,
      6 => :spray,
      -2 => :other_physical_form,
  }.freeze
end
