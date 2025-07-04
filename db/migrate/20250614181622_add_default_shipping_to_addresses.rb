class AddDefaultShippingToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :default_shipping, :boolean, default: false, null: false
  end
end
