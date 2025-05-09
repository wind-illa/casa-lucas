require 'mercadopago'

module PaymentMethods
  class MercadoPagoService
    def initialize(order)
      @order = order
      @token = MercadoPagoToken.find_by(estado: :activo)
      raise "No hay token activo configurado" unless @token
    end

    def process_payment
      mp = Mercadopago::SDK.new(@token.token)


      preference_data = {
        items: [{ title: "Total en productos de tu compra", quantity: 1, currency_id: "ARS", unit_price: @order.total_price.to_f }],

        back_urls: { success: success_url, pending: pending_url, failure: failure_url },
        auto_return: "approved",
        external_reference: @order.id,
        notification_url: "https://www.baratisimo.com.ar/mercado_pago/webhook"
      }

      preference = mp.preference.create(preference_data)
      response = preference.dig(:response)&.with_indifferent_access

      raise "Error al crear la preferencia de pago: #{preference.dig(:response, :message)}" unless preference[:status] == 201 && response[:init_point]

      response[:init_point]
    end

    private

    def success_url
      Rails.application.routes.url_helpers.success_ecommerce_order_url(@order, host: 'www.baratisimo.com.ar', protocol: 'https')

    end

    def pending_url
      success_url
    end

    def failure_url
      Rails.application.routes.url_helpers.payment_ecommerce_order_url(@order, host: 'www.baratisimo.com.ar', protocol: 'https')
    end
  end
end
