class AddUserDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :document_type, :integer
    add_column :users, :document_id, :integer
    add_column :users, :phone, :integer
    add_column :users, :role, :integer
  end
end
