class RemoveBarCodeFromProducts < ActiveRecord::Migration[7.2]
  def change
    remove_column :products, :bar_code, :string
  end
end
