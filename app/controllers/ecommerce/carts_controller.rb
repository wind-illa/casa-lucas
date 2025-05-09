module Ecommerce
  class CartsController < ApplicationController
    before_action :authenticate_user!

    # GET /carrito
    def show
      @cart = current_user.cart || current_user.create_cart
      @cart_items = @cart.cart_items.includes(product: :product_variants).order(id: :desc)
      @total_items = @cart.total_items

      # Obtenemos los detalles del precio del carrito
      total_info = @cart.total_price
      @subtotal = total_info[:subtotal] || 0.0
      @total_price = total_info[:subtotal_with_discount] || 0.0
      @discount_percentage = total_info[:discount_percentage] || 0.0
      @discount_amount = @subtotal - @total_price
    end

    # Vaciar carrito
    def clear_cart
      current_user.cart.cart_items.destroy_all
      redirect_to ecommerce_cart_path, notice: 'El carrito ha sido vaciado exitosamente.'
    end
  end
end
