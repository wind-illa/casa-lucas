class AddNombreToMercadoPagoTokens < ActiveRecord::Migration[7.2]
  def change
    add_column :mercado_pago_tokens, :nombre, :string, null: false
  end
end
