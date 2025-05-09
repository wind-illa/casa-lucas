class CreateBankAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :bank_accounts do |t|
      t.string :tipo
      t.string :numero
      t.string :account_number
      t.string :alias

      t.timestamps
    end
  end
end
