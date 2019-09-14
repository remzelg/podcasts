class CreatePodcasts < ActiveRecord::Migration[5.2]
  def change
    create_table :podcasts do |t|
      t.string :title
      t.string :subtitle
      t.string :author
      t.string :description
      t.string :image_url
      t.timestamps
    end
  end
end
