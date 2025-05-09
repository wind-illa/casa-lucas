class AddCalculationTypeToShippingMethods < ActiveRecord::Migration[7.2]
  def change
    add_column :shipping_methods, :calculation_type, :string, default: "static"
  end
end
