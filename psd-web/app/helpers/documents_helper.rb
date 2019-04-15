module DocumentsHelper
  include FileConcern

  def set_parent
    @parent = Investigation.find_by!(pretty_id: params[:investigation_pretty_id]) if params[:investigation_pretty_id]
    @parent = Product.find(params[:product_id]) if params[:product_id]
    @parent = Business.find(params[:business_id]) if params[:business_id]
    authorize @parent, :show? if @parent.is_a? Investigation
  end

  def document_type_label(document_type)
    case document_type
    when :correspondence_originator
      "Correspondence from originator"
    when :correspondence_business
      "Correspondence from business"
    when :correspondence_other
      "Correspondence from other"
    when :tech_specs
      "Technical specifications"
    when :test_results
      "Test results"
    when :risk_assessment
      "Risk assessment"
    else
      "Other"
    end
  end

  def document_filetype_label(document)
    return "Audio" if document.audio?
    return "Image" if document.image?
    return "Video" if document.video?
    return "Text" if document.text?

    case document.content_type
    when "application/pdf"
      "PDF"
    when "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "Word Document"
    when "application/vnd.ms-excel",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "Excel Document"
    when "application/vnd.ms-powerpoint",
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "PowerPoint Document"
    else
      document_file_extension(document).upcase
    end
  end

  def document_file_extension(document)
    File.extname(document.filename.to_s)&.remove(".")&.upcase
  end

  def pretty_type_description(document)
    description = ""
    description += document_file_extension(document) + ' ' if document_file_extension document
    description + image_document_text(document)
  end

  def formatted_file_updated_date(file)
    if file.blob.metadata[:updated]
      "Updated #{Time.zone.parse(file.blob.metadata[:updated]).strftime('%d/%m/%Y')}"
    end
  end
end
