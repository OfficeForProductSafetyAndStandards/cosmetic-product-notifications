class RemoveTitleAndSubtitleFromActivity < ActiveRecord::Migration[5.2]
  def change
    safety_assured {
      remove_column :activities, :title, :string
      remove_column :activities, :subtitle_slug, :string
    }
  end
end
