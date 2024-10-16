module NotificationPhysicalForms
  extend ActiveSupport::Concern

  included do
    enum physical_form: {
      solid_or_pressed_powder: "solid/pressed powder",
      loose_powder: "loose powder",
      cream_or_paste: "cream/paste",
      liquid: "liquid",
      foam: "foam",
      spray: "spray",
      other_physical_form: "other",
    }
  end
end
