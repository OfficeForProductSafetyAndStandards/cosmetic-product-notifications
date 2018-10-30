class AuditActivity < Activity
  class << self
    include UserService
  end
end
