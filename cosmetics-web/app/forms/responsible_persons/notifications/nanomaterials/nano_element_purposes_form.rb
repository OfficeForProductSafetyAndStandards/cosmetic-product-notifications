module ResponsiblePersons::Notifications::Nanomaterials
  class NanoElementPurposesForm < Form
    STANDARD_TYPE = "standard".freeze
    OTHER_TYPE = NanoElementPurposes.other.name.freeze
    ALLOWED_PURPOSES = NanoElementPurposes.all.map(&:name).freeze

    attribute :purpose_type, :string
    attribute :purposes, array: true, default: []

    attr_reader :purpose_type, :purposes

    validates :purpose_type, presence: true
    validates :purpose_type, inclusion: { in: [STANDARD_TYPE, OTHER_TYPE] }, allow_blank: true
    validates :purposes, presence: true, if: -> { purpose_type == STANDARD_TYPE }
    validate :validate_purposes

    def initialize(purpose_type: nil, purposes: [])
      super
      @purpose_type = initialize_purpose_type(purpose_type, purposes)
      @purposes = initialize_purposes(purposes, purpose_type)
    end

  private

    def initialize_purpose_type(purpose_type, purposes)
      return purpose_type if purpose_type.present?
      return if purposes.blank?

      purposes.include?(OTHER_TYPE) ? OTHER_TYPE : STANDARD_TYPE # infers type from purposes
    end

    def initialize_purposes(purposes, purpose_type)
      purpose_type == OTHER_TYPE ? [OTHER_TYPE] : purposes # For 'other' type, overrides any given standard purpose
    end

    def validate_purposes
      invalid_purposes = (purposes - ALLOWED_PURPOSES)
      invalid_purposes.each { |purpose| errors.add(:purposes, message: :inclusion, purpose:) }

      if purposes.include?(OTHER_TYPE) && purposes.size > 1
        errors.add(:purposes, message: :standard_or_other)
      end
    end
  end
end
