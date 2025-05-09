class CreateShippingMethods < ActiveRecord::Migration[7.2]
  def change
    create_table :shipping_methods do |t|
      t.string :name
      t.text :description
      t.decimal :cost

      t.timestamps
    end
  end
end
