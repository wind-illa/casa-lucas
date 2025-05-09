class ChangeUserIdNullOnCarts < ActiveRecord::Migration[7.2]
  def change
    change_column_null :carts, :user_id, true  # Permitir que user_id sea nulo
  end
end
