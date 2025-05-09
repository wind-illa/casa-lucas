class CreateMercadoPagoTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :mercado_pago_tokens do |t|
      t.string :token, null: false
      t.integer :estado, default: 1 # 'inactivo' por defecto
      t.datetime :fecha_creacion, null: false

      t.timestamps
    end
  end
end
