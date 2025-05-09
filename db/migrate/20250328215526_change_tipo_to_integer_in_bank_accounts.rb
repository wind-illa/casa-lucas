class ChangeTipoToIntegerInBankAccounts < ActiveRecord::Migration[7.2]
  def change
    change_column :bank_accounts, :tipo, :integer, using: 'tipo::integer'
  end
end
