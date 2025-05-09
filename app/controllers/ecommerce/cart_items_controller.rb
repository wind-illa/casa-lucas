module Ecommerce
  class CartItemsController < ApplicationController
    before_action :authenticate_user!


    def create
      product = Product.find(params[:product_id])
      variant = params[:variant_id] ? ProductVariant.find_by(id: params[:variant_id]) : nil

      # Lógica para crear o actualizar el cart_item
      item = if variant.present?
               @cart.cart_items.find_or_initialize_by(product_id: product.id, variant_id: variant.id)
             else
               @cart.cart_items.find_or_initialize_by(product_id: product.id, variant_id: nil)
             end

      item.quantity ||= 0
      item.quantity += 1

      if item.save
        respond_to do |format|
          format.turbo_stream do
            turbo_stream_responses = []

            if variant.present?
              # Renderiza el frame para la variante específica
              turbo_stream_responses << turbo_stream.replace(
                "cart-item-container-variant-#{variant.id}",
                partial: "ecommerce/products/cart_item_variant",
                locals: { cart: @cart, product: product, variant: variant }
              )
            else
              # Renderiza el contenedor general del carrito
              turbo_stream_responses << turbo_stream.replace(
                "cart-item-container",
                partial: "ecommerce/products/cart_items",
                locals: { cart: @cart, product: product }
              )
            end

            # Renderiza el frame para el total de productos en el carrito
            turbo_stream_responses << turbo_stream.replace(
              "cart-item-quantity-nav",
              partial: "ecommerce/products/cart_quantity_nav",
              locals: { cart: @cart }
            )

            render turbo_stream: turbo_stream_responses
          end
          format.html { redirect_to some_path, notice: "Producto agregado al carrito." }

        end
      else
        # Manejo de errores
        render :new, status: :unprocessable_entity
      end
    end

    def update
      # Busca el ítem en el carrito
      item = @cart.cart_items.find_by(id: params[:id])

      if item.nil?
        respond_to do |format|
          # Maneja solicitudes HTML (navegador estándar)
          format.html { redirect_to ecommerce_cart_path, alert: "No se pudo encontrar el producto." }

          # Maneja solicitudes Turbo Stream
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "cart-item-container", # ID del frame afectado
              partial: "shared/full_page_reload", # Parcial que fuerza la redirección
              locals: { redirect_url: ecommerce_cart_path } # URL a redirigir
            )
          end
        end
        return
      end


      if item.update(quantity: params[:quantity])
        @cart_items = @cart.cart_items.includes(:product)

        # Calculamos los nuevos valores del carrito
        total_info = @cart.total_price
        @total_price = total_info[:subtotal_with_discount]
        @discount_percentage = total_info[:discount_percentage]
        @discount_amount = total_info[:subtotal] - total_info[:subtotal_with_discount] # Se calcula el descuento
        @total_price_sin_descuento = total_info[:subtotal]

        

        # Obtener el producto y variante relacionados al ítem del carrito
        product = item.product
        variant = item.variant

        respond_to do |format|
          format.turbo_stream do
            turbo_stream_responses = [
              turbo_stream.replace("cart-item-details-#{item.id}", partial: "ecommerce/carts/cart_item_details", locals: { item: item }),
              turbo_stream.replace("cart-summary", partial: "ecommerce/carts/cart_summary", locals: {
                cart: @cart,
                total_price: @total_price,
                discount_percentage: @discount_percentage,
                discount_amount: @discount_amount,
                total_price_sin_descuento: @total_price_sin_descuento
              })
            ]

            if variant.present?
              # Renderiza el contenedor específico de la variante
              turbo_stream_responses << turbo_stream.replace(
                "cart-item-container-variant-#{variant.id}",
                partial: "ecommerce/products/cart_item_variant",
                locals: { cart: @cart, product: product, variant: variant }
              )
            else
              # Renderiza el contenedor general del carrito
              turbo_stream_responses << turbo_stream.replace(
                "cart-item-container",
                partial: "ecommerce/products/cart_items",
                locals: { cart: @cart, product: product }
              )
            end

            # Renderiza el total de ítems en el carrito
            turbo_stream_responses << turbo_stream.replace(
              "cart-item-quantity-nav",
              partial: "ecommerce/products/cart_quantity_nav",
              locals: { cart: @cart }
            )

            render turbo_stream: turbo_stream_responses
          end
        end
      else
        # Maneja errores de actualización
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "cart-item-#{item.id}",
              partial: "ecommerce/carts/cart_item",
              locals: { item: item, error: "No se pudo actualizar el producto." }
            )
          end
          format.html { redirect_to ecommerce_cart_path, alert: "No se pudo actualizar el producto." }
        end
      end
    end



    def destroy
      item = @cart.cart_items.find(params[:id])
      variant = item.variant # Identifica si el ítem tiene una variante
      product = item.product # Obtiene el producto relacionado
      item.destroy

      # Calculamos los nuevos valores del carrito después de eliminar el ítem
      total_info = @cart.total_price
      @total_price = total_info[:subtotal_with_discount]
      @discount_percentage = total_info[:discount_percentage]
      @discount_amount = total_info[:subtotal] - total_info[:subtotal_with_discount] # Se calcula el descuento
      @total_price_sin_descuento = total_info[:subtotal]

      # Volvemos a cargar los productos del carrito
      @cart_items = @cart.cart_items.includes(:product)

      respond_to do |format|
        format.turbo_stream do
          turbo_stream_responses = [
            # Elimina el ítem del carrito
            turbo_stream.remove("cart-item-details-#{item.id}"),

            # Actualiza el resumen del carrito
            turbo_stream.replace("cart-summary", partial: "ecommerce/carts/cart_summary", locals: {
              cart: @cart,
              total_price: @total_price,
              discount_percentage: @discount_percentage,
              discount_amount: @discount_amount,
              total_price_sin_descuento: @total_price_sin_descuento
            })
          ]

          if variant.present?
            # Renderiza el frame para la variante específica
            turbo_stream_responses << turbo_stream.replace(
              "cart-item-container-variant-#{variant.id}",
              partial: "ecommerce/products/cart_item_variant",
              locals: { cart: @cart, product: product, variant: variant }
            )
          else
            # Actualiza el contenedor general del carrito si no hay variante
            turbo_stream_responses << turbo_stream.replace(
              "cart-item-container",
              partial: "ecommerce/products/cart_items",
              locals: { cart: @cart, product: product }
            )
          end

          # Actualiza el total de items en el carrito
          turbo_stream_responses << turbo_stream.replace(
            "cart-item-quantity-nav",
            partial: "ecommerce/products/cart_quantity_nav",
            locals: { cart: @cart }
          )

          render turbo_stream: turbo_stream_responses
        end

        # Si no es Turbo, realiza una redirección normal
        format.html { redirect_to ecommerce_cart_path, notice: "Producto eliminado del carrito." }
      end
    end


    private



  end
end
