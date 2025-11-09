class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.string :slug
      t.string :image_url
      t.string :category

      t.timestamps
    end
  end
end
