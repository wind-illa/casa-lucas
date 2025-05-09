class AddPriceIncreasePercentageToSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :settings, :price_increase_percentage, :decimal
  end
end
