class Correspondence::PhoneCall < Correspondence
  has_one_attached :transcript

  def validate_transcript_and_content file_blob
    if file_blob.nil? && overview.empty? && details.empty?
      errors.add(:phone_call, "- please provide either a transcript or complete the summary and notes fields")
    end
  end
end
