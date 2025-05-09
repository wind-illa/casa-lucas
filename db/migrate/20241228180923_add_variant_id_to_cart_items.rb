class AddVariantIdToCartItems < ActiveRecord::Migration[7.2]
  def change
    add_column :cart_items, :variant_id, :integer
  end
end
