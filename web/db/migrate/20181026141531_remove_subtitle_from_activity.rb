class RemoveSubtitleFromActivity < ActiveRecord::Migration[5.2]
  def change
    safety_assured {
      remove_column :activities, :subtitle_slug, :string
    }
  end
end
