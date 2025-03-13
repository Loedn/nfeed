class AddCategoryToCollections < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :category, :string
    add_index :collections, :category
  end
end 