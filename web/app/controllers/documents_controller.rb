class DocumentsController < FilesController
  include FileConcern
  set_attachment_categories :file
  set_file_params_key :document

  include DocumentsHelper
end
