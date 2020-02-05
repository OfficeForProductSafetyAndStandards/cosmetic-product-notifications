class DomainExclusionConstraint
  def initialize(domains)
    @domains = domains.split(",").map(&:strip)
  end

  def matches?(request)
    !@domains.include?(request.host)
  end
end
