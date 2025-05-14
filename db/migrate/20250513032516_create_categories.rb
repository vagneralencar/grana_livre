class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :category_type
      t.references :user, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :categories } # Alterado para null: true e especificado to_table

      t.timestamps
    end
    add_index :categories, [:user_id, :name, :category_type], unique: true, name: "index_categories_on_user_name_type"
  end
end

