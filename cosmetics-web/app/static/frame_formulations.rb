module FrameFormulations
  SKIN_CARE                = JSON.parse(File.read("app/static/data/01-skin-care.json"))
  SKIN_CLEANSING           = JSON.parse(File.read("app/static/data/02-skin-cleansing.json"))
  HAIR_REMOVEAL            = JSON.parse(File.read("app/static/data/03-hair-removal.json"))
  BLEACH_FOR_BODY_HAIR     = JSON.parse(File.read("app/static/data/04-bleach-for-body-hair.json"))
  CORRECTION_OF_BODY_ODOUR = JSON.parse(File.read("app/static/data/05-correction-of-body-odour-and-or-perspiration.json"))
  SHAVING_PRODUCTS         = JSON.parse(File.read("app/static/data/06-shaving-products.json"))
  MAKE_UP                  = JSON.parse(File.read("app/static/data/07-make-up.json"))
  PERFUMES                 = JSON.parse(File.read("app/static/data/08-perfumes.json"))
  SUN_PRODUCTS             = JSON.parse(File.read("app/static/data/09-sun-products-and-self-tanning-products.json"))
  HAIR_CARE_PRODUCT        = JSON.parse(File.read("app/static/data/10-hair-and-scalp-care-products.json"))
  HAIR_COLOURING_PRODUCTS  = JSON.parse(File.read("app/static/data/11-hair-colouring-products.json"))
  HAIR_STYLING_PRODUCTS    = JSON.parse(File.read("app/static/data/12-hair-styling-products.json"))
  NAIL_VARNISH             = JSON.parse(File.read("app/static/data/13-nail-varnish.json"))
  NAIL_CONDITIONER         = JSON.parse(File.read("app/static/data/14-Nail-conditioner.json"))
  TOOTHPASTE               = JSON.parse(File.read("app/static/data/16-toothpaste.json"))
  MOUTHWASH                = JSON.parse(File.read("app/static/data/17-mouthwash.json"))

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
end
