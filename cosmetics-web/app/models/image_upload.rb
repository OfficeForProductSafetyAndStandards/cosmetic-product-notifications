class ImageUpload < ApplicationRecord
    belongs_to :notification
    
    has_one_attached :file
end
