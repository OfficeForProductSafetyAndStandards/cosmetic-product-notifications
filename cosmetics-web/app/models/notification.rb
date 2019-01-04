class Notification < ApplicationRecord
    belongs_to :responsible_person
    has_many :components
    has_many :image_files
end
