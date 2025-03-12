class CreateFeeds < ActiveRecord::Migration[6.1]
  def change
    create_table :feeds do |t|
      t.references :collection, null: false, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.text :description
      t.text :items, default: '[]'  # Store as serialized JSON text
      t.datetime :last_fetched_at
      t.string :status
      t.text :fetch_error

      t.timestamps
    end
    
    add_index :feeds, [:collection_id, :url], unique: true
  end
end 