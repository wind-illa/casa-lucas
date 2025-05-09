class AddDiscountFieldsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :subtotal, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :orders, :discount_amount, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :orders, :subtotal_with_discount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end

