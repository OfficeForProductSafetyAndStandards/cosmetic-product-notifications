class AddEmailSubjectDirectionAndAttachmentDescriptionToCorrespondence < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :correspondences, bulk: true do |t|
        t.string "email_direction"
        t.string "email_subject"
      end
    end
  end
end
