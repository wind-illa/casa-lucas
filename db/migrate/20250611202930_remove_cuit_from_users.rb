class RemoveCuitFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :cuit, :string
  end
end
