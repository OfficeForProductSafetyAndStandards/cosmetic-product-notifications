class DomainCheck
  def initialize(domains)
    @domains = domains.split(',')
  end

  def matches?(request)
    !@domains.include?(request.host)
  end
end

