class ChangePhoneTypeInUsers < ActiveRecord::Migration[7.2]
  def up
    change_column :users, :phone, :string
  end

  def down
    change_column :users, :phone, :integer
  end
end
