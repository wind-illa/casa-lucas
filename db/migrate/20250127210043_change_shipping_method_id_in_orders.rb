class ChangeShippingMethodIdInOrders < ActiveRecord::Migration[7.2]
  def change
    change_column_null :orders, :payment_method_id, true
    change_column_null :orders, :shipping_method_id, true
  end
end
