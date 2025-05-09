class ChangeColorsToBeStringInProducts < ActiveRecord::Migration[7.2]
  def change
    change_column :products, :colors, :string
  end
end
