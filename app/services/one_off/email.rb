module OneOff
  class Email
    def initialize(email)
      @email = email.strip
      extract_names
    end

    attr_reader :email, :name

  private

    def extract_names
      splited = email.split("@")
      if splited.length != 2
        @email = nil
        return
      end

      @name = splited[0].split(".").map(&:capitalize).join(" ")
    rescue StandardError
      @email = nil
    end
  end
end
