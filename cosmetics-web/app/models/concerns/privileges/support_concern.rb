module Privileges
  module SupportConcern
    include AbstractConcern

    def opss_general_user?
      true
    end
  end
end
