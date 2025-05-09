class AddShippingCostToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :shipping_cost, :decimal, precision: 10, scale: 2
  end
end
