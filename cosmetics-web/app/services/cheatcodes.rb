module Cheatcodes
  def self.image_cloner(notification)
    UnusedCodeAlerting.alert
    filenames = notification.image_uploads.map(&:file).map(&:blob).map(&:filename).map(&:to_s)
    if filenames.include? "our_tester_wants_an_exception_OMG.jpg"
      raise Errno::ECONNRESET
    elsif filenames.include? "our_tester_wants_to_wait_OMG.jpg"
      sleep 90
    end
  end
end
