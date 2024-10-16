class NanoMaterialPurposes
  Purpose = Struct.new(:name, :display_name, :annex_number, :link, keyword_init: true) do
    def upcase_display_name
      display_name.upcase_first
    end
  end

  COLORANT = Purpose.new(
    name: "colorant",
    display_name: "colourant",
    annex_number: 4,
    link: "https://www.legislation.gov.uk/eur/2009/1223/annex/IV",
  ).freeze

  PRESERVATIVE = Purpose.new(
    name: "preservative",
    display_name: "preservative",
    annex_number: 5,
    link: "https://www.legislation.gov.uk/eur/2009/1223/annex/V",
  ).freeze

  UV_FILTER = Purpose.new(
    name: "uv_filter",
    display_name: "UV filter",
    annex_number: 6,
    link: "https://www.legislation.gov.uk/eur/2009/1223/annex/VI",
  ).freeze

  OTHER = Purpose.new(
    name: "other",
    display_name: "another purpose",
    annex_number: nil,
    link: "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32009R1223",
  ).freeze

  STANDARD_PURPOSES = [COLORANT, PRESERVATIVE, UV_FILTER].freeze
  ALL_PURPOSES = (STANDARD_PURPOSES + [OTHER]).freeze

  private_constant :COLORANT, :PRESERVATIVE, :UV_FILTER, :OTHER, :STANDARD_PURPOSES, :ALL_PURPOSES

  class << self
    def find(purpose) = ALL_PURPOSES.find { |p| p.name == purpose }
    def all = ALL_PURPOSES
    def standard = STANDARD_PURPOSES
    def colorant = COLORANT
    def preservative = PRESERVATIVE
    def uv_filter = UV_FILTER
    def other = OTHER
  end
end
