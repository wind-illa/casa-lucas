class CreateBarCodes < ActiveRecord::Migration[7.2]
  def change
    create_table :bar_codes do |t|
      t.string :code
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
