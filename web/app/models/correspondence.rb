class Correspondence < ApplicationRecord
  belongs_to :investigation, required: false
end
