class CreateSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :settings do |t|
      t.decimal :iva_percentage
      t.decimal :profit_margin_ecommerce
      t.decimal :profit_margin_business
      t.decimal :dollar_rate
      t.string :price_input_type

      t.timestamps
    end
  end
end
