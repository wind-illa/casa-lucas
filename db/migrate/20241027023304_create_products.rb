class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :sku
      t.string :product_name
      t.string :bar_code
      t.decimal :price
      t.integer :price_discount
      t.string :brand
      t.text :product_description
      t.integer :colors
      t.decimal :weight
      t.decimal :height
      t.decimal :width
      t.decimal :length
      t.integer :stock_quantity

      t.timestamps
    end
  end
end
