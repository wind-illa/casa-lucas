class AddMercadoPagoPaymentMethodToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :mercado_pago_payment_method, :string
  end
end
