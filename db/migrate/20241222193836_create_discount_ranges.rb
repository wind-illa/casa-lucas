class CreateDiscountRanges < ActiveRecord::Migration[7.2]
  def change
    create_table :discount_ranges do |t|
      t.decimal :min_amount
      t.decimal :discount_percentage

      t.timestamps
    end
  end
end
