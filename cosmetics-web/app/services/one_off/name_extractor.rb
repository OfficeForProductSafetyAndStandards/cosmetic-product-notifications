module OneOff
  class NameExtractor
    def initialize(email)
      @email = email
      extract_names
    end

    def email
      @email
    end

    def name
      @name
    end

    private

    def extract_names
      splited = email.split('@')
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
