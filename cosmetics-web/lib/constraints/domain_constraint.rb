class DomainConstraint
  def initialize(domains)
    raise "No domains specified" unless domains

    @domains = domains.split(',')
  end

  def matches?(request)
    @domains.include?(request.host)
  end
end
