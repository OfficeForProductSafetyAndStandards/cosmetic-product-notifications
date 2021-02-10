module OneOff
  class SearchUserBulkInviter
    def initialize(filepath, role)
      @filepath = filepath
      @role = role
    end

    def call
      emails.each do |email|
        next if email.name.nil? || email.email.nil?

        begin
          InviteSearchUser.call name: email.name, email: email.email, role: @role
        rescue ActiveRecord::RecordInvalid
          next
        end
      end
    end

  private

    def emails
      result = []
      File.open(@filepath).each_line do |email|
        result << Email.new(email)
      end
      result
    end
  end
end
