class RemoveFechaCreacionFromMercadoPagoTokens < ActiveRecord::Migration[7.2]
  def change
    remove_column :mercado_pago_tokens, :fecha_creacion, :datetime
  end
end
