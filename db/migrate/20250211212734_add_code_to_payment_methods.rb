class AddCodeToPaymentMethods < ActiveRecord::Migration[7.2]
  def change
    add_column :payment_methods, :code, :string
    add_index :payment_methods, :code, unique: true
  end
end
