
module OrdersHelper
  def status_class(status)
    case status
    when "pendiente"
      "status-pending"
    when "pago_pendiente"
      "status-payment-pending"
    when "pagado"
      "status-paid"
    when "en_preparacion"
      "status-in-preparation"
    when "listo_para_retirar"
      "status-ready-for-pickup"
    when "enviado"
      "status-shipped"
    when "entregado"
      "status-delivered"
    when "cancelado"
      "status-canceled"
    else
      "status-unknown"
    end
  end
end
