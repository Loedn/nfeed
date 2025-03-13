class CreateFeedItems < ActiveRecord::Migration[8.0] 
  def change
    create_table :feed_items do |t|
      t.references :feed, null: false, foreign_key: true
      t.string :title, null: false
      t.string :link, null: false
      t.text :description
      t.datetime :published_at
      t.string :guid
      t.boolean :is_video, default: false
      t.boolean :is_audio, default: false
      t.string :author
      t.string :categories
      t.string :enclosure_url
      t.string :enclosure_type
      
      t.timestamps
    end
    
    add_index :feed_items, [:feed_id, :guid], unique: true, name: 'index_feed_items_on_feed_id_and_guid'
    add_index :feed_items, :published_at
  end
end 