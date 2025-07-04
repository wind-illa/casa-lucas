class AddAddressTypeToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :address_type, :integer, null: false, default: 0
  end
end
