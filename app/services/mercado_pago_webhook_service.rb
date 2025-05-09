class MercadoPagoWebhookService
  def self.process_webhook(params)
    return if params[:data].nil? || params[:data][:external_reference].nil? || params[:data][:status].nil?

    order_id = params[:data][:external_reference]
    payment_status = params[:data][:status]
    payment_id = params[:data][:id]
    mercado_pago_payment_method = params[:data][:payment_method_id]

    return if order_id.nil? || payment_status.nil? || payment_id.nil?

    order = Order.find_by(id: order_id)
    return unless order

    new_status = case payment_status
                 when "approved" then :pagado
                 when "pending" then :pago_pendiente
                 when "rejected", "cancelled", "refunded", "charged_back" then :cancelado
                 else :desconocido
                 end

    order.update!(
      status: new_status,
      mercado_pago_payment_method: mercado_pago_payment_method,
      mercado_pago_transaction_id: payment_id
    )
  rescue => e
    Rails.logger.error("Error en MercadoPagoWebhookService: #{e.message}")
  end
end
