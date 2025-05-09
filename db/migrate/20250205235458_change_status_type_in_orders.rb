class ChangeStatusTypeInOrders < ActiveRecord::Migration[7.2]
  def change
    remove_column :orders, :status, :string
    add_column :orders, :status, :integer, default: 0, null: false
  end
end
