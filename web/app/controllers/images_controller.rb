class ImagesController < FilesController
  include FileConcern
  set_attachment_names :file
  set_file_params_key :image

  include ImagesHelper
end
