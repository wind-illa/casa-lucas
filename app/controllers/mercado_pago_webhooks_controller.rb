# app/controllers/mercado_pago_webhooks_controller.rb
class MercadoPagoWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    Rails.logger.info "MercadoPago Webhook Params: #{params.inspect}"

    MercadoPagoWebhookService.process_webhook(params)
    head :ok
  rescue => e
    logger.error("Error al procesar el webhook: #{e.message}")
    head :bad_request
  end
end
