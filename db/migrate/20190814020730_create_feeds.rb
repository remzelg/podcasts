class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds do |t|
      t.string    :itunes_url, null: false, index: { unique: true }
      t.string    :itunes_title, null: false, index: { unique: true }
      t.string    :itunes_id, null: false, index: { unique: true }
      t.string    :rss_url
      t.boolean   :active, default: false
      t.boolean   :out_of_date, default: false
      t.datetime  :last_import_date
      t.timestamps
    end
  end
end
