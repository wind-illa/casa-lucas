class ChangeDocumentIdToStringInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :document_id, :string
  end
end
