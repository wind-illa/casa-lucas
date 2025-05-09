class ChangeDiscountAmountToPercentageInOrders < ActiveRecord::Migration[7.2]
  def change
    rename_column :orders, :discount_amount, :discount_percentage
    change_column :orders, :discount_percentage, :decimal, precision: 5, scale: 2, default: "0.0", comment: "Porcentaje de descuento aplicado"
  end
end
