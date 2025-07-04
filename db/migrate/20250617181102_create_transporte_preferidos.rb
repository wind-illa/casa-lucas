class CreateTransportePreferidos < ActiveRecord::Migration[8.0]
  def change
    create_table :transporte_preferidos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :nombre
      t.boolean :predeterminado
      t.text :observaciones

      t.timestamps
    end
  end
end
