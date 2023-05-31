class DomainInclusionConstraint
  def initialize(*domains)
    raise "No domains specified" if domains.blank?

    @domains = domains.map(&:strip)
  end

  def matches?(request)
    @domains.include?(request.host)
  end
end
