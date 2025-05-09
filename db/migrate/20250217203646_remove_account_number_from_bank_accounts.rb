class RemoveAccountNumberFromBankAccounts < ActiveRecord::Migration[7.2]
  def change
    remove_column :bank_accounts, :account_number, :string
  end
end
