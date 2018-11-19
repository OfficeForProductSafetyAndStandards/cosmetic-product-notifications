class ImagesFlowController < FilesFlowController
  include FileConcern
  set_attachment_categories :file
  set_file_params_key :image

  include ImagesHelper
end
