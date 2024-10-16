module FrameFormulations
  # Category hierarchy
  CATEGORIES               = JSON.parse(File.read("app/assets/files/frame_formulations/categories.json"))
  # "Other" entries (generally one per lowest-level category) which aren't actual frame formulations
  OTHER                    = JSON.parse(File.read("app/assets/files/frame_formulations/other.json"))
  # Frame formulations that cannot be selected for new notifications but are kept for existing notifications
  VIEW_ONLY                = JSON.parse(File.read("app/assets/files/frame_formulations/view_only.json"))

  SKIN_CARE                = JSON.parse(File.read("app/assets/files/frame_formulations/01-skin-care.json"))
  SKIN_CLEANSING           = JSON.parse(File.read("app/assets/files/frame_formulations/02-skin-cleansing.json"))
  HAIR_REMOVEAL            = JSON.parse(File.read("app/assets/files/frame_formulations/03-hair-removal.json"))
  BLEACH_FOR_BODY_HAIR     = JSON.parse(File.read("app/assets/files/frame_formulations/04-bleach-for-body-hair.json"))
  CORRECTION_OF_BODY_ODOUR = JSON.parse(File.read("app/assets/files/frame_formulations/05-correction-of-body-odour-and-or-perspiration.json"))
  SHAVING_PRODUCTS         = JSON.parse(File.read("app/assets/files/frame_formulations/06-shaving-products.json"))
  MAKE_UP                  = JSON.parse(File.read("app/assets/files/frame_formulations/07-make-up.json"))
  PERFUMES                 = JSON.parse(File.read("app/assets/files/frame_formulations/08-perfumes.json"))
  SUN_PRODUCTS             = JSON.parse(File.read("app/assets/files/frame_formulations/09-sun-products-and-self-tanning-products.json"))
  HAIR_CARE_PRODUCT        = JSON.parse(File.read("app/assets/files/frame_formulations/10-hair-and-scalp-care-products.json"))
  HAIR_COLOURING_PRODUCTS  = JSON.parse(File.read("app/assets/files/frame_formulations/11-hair-colouring-products.json"))
  HAIR_STYLING_PRODUCTS    = JSON.parse(File.read("app/assets/files/frame_formulations/12-hair-styling-products.json"))
  NAIL_VARNISH             = JSON.parse(File.read("app/assets/files/frame_formulations/13-nail-varnish.json"))
  NAIL_CONDITIONER         = JSON.parse(File.read("app/assets/files/frame_formulations/14-nail-conditioner.json"))
  TOOTHPASTE               = JSON.parse(File.read("app/assets/files/frame_formulations/16-toothpaste.json"))
  MOUTHWASH                = JSON.parse(File.read("app/assets/files/frame_formulations/17-mouthwash.json"))

  ALL = [
    SKIN_CARE,
    SKIN_CLEANSING,
    HAIR_REMOVEAL,
    BLEACH_FOR_BODY_HAIR,
    CORRECTION_OF_BODY_ODOUR,
    SHAVING_PRODUCTS,
    MAKE_UP,
    PERFUMES,
    SUN_PRODUCTS,
    HAIR_CARE_PRODUCT,
    HAIR_COLOURING_PRODUCTS,
    HAIR_STYLING_PRODUCTS,
    NAIL_VARNISH,
    NAIL_CONDITIONER,
    TOOTHPASTE,
    MOUTHWASH,
  ].freeze

  ALL_PLUS_OTHER = [
    ALL,
    OTHER,
  ].flatten.freeze

  ALL_PLUS_OTHER_AND_VIEW_ONLY = [
    ALL,
    OTHER,
    VIEW_ONLY,
  ].flatten.extend(Hashie::Extensions::DeepLocate).freeze
end
