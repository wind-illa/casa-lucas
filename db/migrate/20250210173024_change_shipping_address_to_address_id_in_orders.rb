class ChangeShippingAddressToAddressIdInOrders < ActiveRecord::Migration[7.2]
  def change
    remove_column :orders, :shipping_address
    add_column :orders, :address_id, :bigint
    add_foreign_key :orders, :addresses
  end
end

