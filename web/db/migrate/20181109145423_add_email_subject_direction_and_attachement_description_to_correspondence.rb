class AddEmailSubjectDirectionAndAttachementDescriptionToCorrespondence < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :correspondences do |t|
        t.string "email_direction"
        t.text "attachment_description"
        t.string "email_subject"
      end
    end
  end
end
