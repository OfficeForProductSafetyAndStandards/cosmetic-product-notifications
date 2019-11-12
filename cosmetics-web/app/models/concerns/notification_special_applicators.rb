module NotificationSpecialApplicators
  extend ActiveSupport::Concern

  included do
    enum special_applicator: {
        wipe_sponge_patch_pad: "wipe/sponge/patch/pad",
        encapsulated_products: "encapsulated products",
        pressurised_spray_container: "pressurised spray container",
        pressurised_container_non_spray_product: "pressurised container - non spray product",
        other_special_applicator: "other",
    }
  end
end
