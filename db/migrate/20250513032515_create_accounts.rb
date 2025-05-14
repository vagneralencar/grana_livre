class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.string :name
      t.decimal :initial_amount
      t.decimal :current_amount
      t.boolean :include_in_reports
      t.boolean :allow_negative_amount
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
