module Ecommerce
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_cart
    before_action :set_order, except: [:new, :index]
    before_action :set_navbar_visibility, only: [:shipping_info, :shipping, :payment, :summary, :success]


    def index
      if params[:query_texto].present?
        @orders = current_user.orders.search_full_text(params[:query_texto]).order(created_at: :desc).page(params[:page]).per(10)
      else
        @orders = current_user.orders.order(created_at: :desc).page(params[:page]).per(10)
      end
    end



    def show
    end

    def new
      clean_pending_orders
      @order = create_new_order
      add_cart_items_to_order
      calculate_totals
      redirect_to shipping_info_ecommerce_order_path(@order)
    end

    def shipping_info
      @addresses = current_user.addresses
      @selected_address_id = @order.address_id
      calculate_totals
    end

    def update_shipping_info
      if update_order_address
        redirect_to shipping_ecommerce_order_path(@order)
      else
        redirect_to shipping_info_ecommerce_order_path(@order), alert: "Error al actualizar la dirección de envío"
      end
    end

    def shipping
      @shipping_methods = ShippingMethod.all
      calculate_totals
      @addresses = current_user.addresses
    end

    def update_shipping
      if update_shipping_method
        redirect_to payment_ecommerce_order_path(@order)
      else
        redirect_to shipping_ecommerce_order_path(@order), alert: "Error al actualizar el método de envío"
      end
    end

    def pdf
      pdf = OrderPdf.new(@order)
      send_data pdf.render,
                filename: "orden_#{@order.id}.pdf",
                type: "application/pdf",
                disposition: "inline"
    end


    def payment
      @payment_methods = PaymentMethod.all
      calculate_totals
    end

    def update_payment
      if update_payment_method
        redirect_to summary_ecommerce_order_path(@order)
      else
        redirect_to payment_ecommerce_order_path(@order), alert: "Error al actualizar el método de pago"
      end
    end

    def summary
      calculate_totals
    end

    def finalize
      payment_method = PaymentMethod.find(@order.payment_method_id)
      if payment_method.code == "mercado_pago"
        redirect_to PaymentMethods::MercadoPagoService.new(@order).process_payment, allow_other_host: true
      else
        complete_order
        redirect_to success_ecommerce_order_path(@order)
      end
    end

    def success
      @order = current_user.orders.find(params[:id])
      return unless @order.payment_method.code == "mercado_pago"

      payment_id = params[:payment_id]
      payment_status = params[:status] || "approved"
      mercado_pago_method = params[:payment_type] || 'unknown'

      @order.update(mercado_pago_payment_method: mercado_pago_method, mercado_pago_transaction_id: payment_id) if payment_id.present?

      if payment_status == "rejected"
        flash[:alert] = "Tu pago fue rechazado. Por favor, elegí otro método de pago."
        redirect_to payment_ecommerce_order_path(@order) and return
      end

      new_status = case payment_status
                   when "approved"      then :pagado
                   when "pending", "in_process" then :pago_pendiente
                   when "cancelled"     then :cancelado
                   else :desconocido
                   end

      @order.transaction do
        calculate_totals
        @order.update!(status: new_status, total_price: @order_total, shipping_cost: @shipping_cost)
        @cart.cart_items.destroy_all
      end
    end



    # def upload_comprobante
    #   if @order.update(comprobante_params)
    #     redirect_to ecommerce_order_path(@order), notice: "Comprobante subido correctamente."
    #   else
    #     redirect_to ecommerce_order_path(@order), alert: "Error al subir el comprobante."
    #   end
    # end

    def upload_comprobante
      if params[:order][:comprobante].present?
        processed = ImageProcessing::MiniMagick
                      .source(params[:order][:comprobante])
                      .resize_to_limit(1200, 1200)
                      .convert("webp")
                      .call

        @order.comprobante.purge if @order.comprobante.attached?
        @order.comprobante.attach(
          io: processed,
          filename: "comprobante_#{@order.id}.webp",
          content_type: "image/webp"
        )

        redirect_to ecommerce_order_path(@order), notice: "Comprobante subido correctamente."
      else
        redirect_to ecommerce_order_path(@order), alert: "Debés seleccionar un archivo."
      end
    end


    def cancel
      if @order.pago_pendiente?
        @order.update!(status: :cancelado)

        redirect_to ecommerce_orders_path, notice: "La orden ha sido cancelada con éxito."
      else
        redirect_to ecommerce_order_path(@order), alert: "No se puede cancelar una orden en este estado."
      end
    end



    private  #------------------------------------------------------------------------------

    def comprobante_params
      params.require(:order).permit(:comprobante)
    end

    def set_navbar_visibility
      @hide_navbar = true
    end

    def set_cart
      @cart = current_user.cart
    end

    def set_order
      @order = current_user.orders.find_by(id: params[:id])
      unless @order
        redirect_to ecommerce_cart_path, alert: "La orden ya no está disponible. Te hemos redirigido a tu carrito."
      end
    end

    def order_params
      params.require(:order).permit(:shipping_method_id, :payment_method_id, :address_id)
    end

    def clean_pending_orders
      current_user.orders.where(status: :pendiente).destroy_all
    end

    def create_new_order
      current_user.orders.create!(total_price: 0, status: :pendiente)
    end

    def add_cart_items_to_order
      @cart.cart_items.each do |item|
        @order.order_items.create!(
          product: item.product,
          variant: item.variant,
          quantity: item.quantity,
          price: item.product.price
        )
      end
    end

    def update_order_address
      address_id = order_params[:address_id]
      return false unless address_id.present?
      @order.update(address_id: address_id)
    end

    def update_shipping_method
      shipping_method = ShippingMethod.find_by(id: order_params[:shipping_method_id])
      return false unless shipping_method

      shipping_cost = calculate_shipping_cost(shipping_method)
      @order.update(shipping_method_id: shipping_method.id, shipping_cost: shipping_cost)
    end

    def calculate_shipping_cost(shipping_method)
      if shipping_method.dynamic?
        address = @order.address || current_user.addresses.first
        weight = @cart.total_weight
        shipping_method.calculator.calculate_cost(address, weight)
      else
        shipping_method.calculator.calculate_cost(nil, nil)
      end
    end

    def update_payment_method
      payment_method_id = order_params[:payment_method_id]
      return false unless payment_method_id.present?
      @order.update(payment_method_id: payment_method_id)
    end

    def complete_order
      @order.transaction do
        calculate_totals
        new_status = if @order.payment_method.code.in?(["transferencia", "efectivo"])
                      :pago_pendiente
                    else
                      :pagado
                    end
        @order.update!(
          status: new_status,
          total_price: @order_total, # Asegúrate de guardar el total_price
          shipping_cost: @shipping_cost # Asegúrate de guardar el shipping_cost
        )
          Rails.logger.info "Order after update: #{@order.inspect}"

        @cart.cart_items.destroy_all # Vacía el carrito
      end
    end

    def calculate_totals
      total_price_data = @cart.total_price

      # Asigna los datos calculados a la orden
      @order.subtotal = total_price_data[:subtotal]
      @order.discount_percentage = total_price_data[:discount_percentage] # Guardamos el porcentaje
      @order.subtotal_with_discount = total_price_data[:subtotal_with_discount]

      address = @order.address || current_user.addresses.first
      @shipping_cost = if @order.shipping_method&.dynamic?
                         weight = @cart.total_weight
                         @order.shipping_method.calculator.calculate_cost(address, weight)
                       else
                         @order.shipping_method&.cost || 0
                       end

      @order_total = @order.subtotal_with_discount + @shipping_cost
      @order.shipping_cost = @shipping_cost
      @order.total_price = @order_total

      @order.save!
    end

  end
end



# def redirect_to_payment_or_summary
#   payment_method = PaymentMethod.find(@order.payment_method_id)
#   if payment_method.code == "mercado_pago"
#     redirect_to PaymentMethods::MercadoPagoService.new(@order).process_payment, allow_other_host: true
#   else
#     redirect_to summary_ecommerce_order_path(@order)
#   end
# end
