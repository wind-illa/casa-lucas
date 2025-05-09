class AddEstadoToBankAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :bank_accounts, :estado, :integer, default: 1
  end
end
