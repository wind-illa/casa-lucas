class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :street_name
      t.integer :street_number
      t.integer :floor
      t.string :apartment
      t.string :locality
      t.string :city
      t.string :province_code
      t.integer :postal_code
      t.string :indications

      t.timestamps
    end
  end
end
