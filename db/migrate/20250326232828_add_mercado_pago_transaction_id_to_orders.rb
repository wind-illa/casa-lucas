class AddMercadoPagoTransactionIdToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :mercado_pago_transaction_id, :string, comment: "Número de transacción de Mercado Pago"
  end
end
