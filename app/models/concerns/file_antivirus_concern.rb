module FileAntivirusConcern
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :attachment_name_for_antivirus

  private

    def set_attachment_name_for_antivirus(name)
      @attachment_name_for_antivirus = name
    end
  end

  def attachment_name_for_antivirus
    self.class.attachment_name_for_antivirus
  end

  def file_exists?
    send(attachment_name_for_antivirus).attachment.present?
  end

  def failed_antivirus_check?
    file_exists? && virus_safe == false
  end

  def passed_antivirus_check?
    # We want to return 'false' (not nil) when the virus_safe is 'nil'
    file_exists? && virus_safe == true
  end

  def pending_antivirus_check?
    file_exists? && virus_safe.nil?
  end

private

  def virus_safe
    return true if ENV["ANTIVIRUS_ENABLED"] == "false"

    send(attachment_name_for_antivirus).metadata["safe"]
  end
end
