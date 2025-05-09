class AddDefaultToPriceIncreasePercentageInSettings < ActiveRecord::Migration[7.2]
  def change
    change_column_default :settings, :price_increase_percentage, 0.0
  end
end
