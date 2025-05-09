class AddSubcategoryIdToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :subcategory_id, :bigint
  end
end
