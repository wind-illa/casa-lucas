class CreateCarts < ActiveRecord::Migration[7.2]
  def change
    create_table :carts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :session_id

      t.timestamps
    end

    add_index :carts, :session_id, unique: true
  end
end
