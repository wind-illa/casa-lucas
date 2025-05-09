module Admin
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_order, only: [:show, :update, :destroy, :cambiar_estado]
    before_action :set_orders_count, only: [:home, :pendientes, :pagos, :preparacion, :finalizadas]
    before_action :set_navbar_title

    def home
      @recent_orders = Order.order(created_at: :desc).limit(10) # Últimas 10 órdenes
      @recent_payments = Order.where(status: [1, 2]).order(updated_at: :desc).limit(5) # Últimos pagos
      @recent_preparations = Order.where(status: 3).order(updated_at: :desc).limit(5) # Últimas en preparación
    end

    def pendientes
      @orders = if params[:query_text].present?
                  Order.where(status: 0).search_full_text(params[:query_text])
                else
                  Order.where(status: 0).order(created_at: :desc)
                end.page(params[:page]).per(20) # Paginación con 20 órdenes por página
      @pendientes_count = @orders.total_count # Para contar todas las órdenes sin afectar la paginación
    end

    def pagos
      @orders = if params[:query_text].present?
                  Order.where(status: [1, 2]).search_full_text(params[:query_text])
                else
                  Order.where(status: [1, 2]).order(created_at: :desc)
                end
      @pagos_count = @orders.count
    end

    def preparacion
      @orders = if params[:query_text].present?
                  Order.where(status: [3, 4, 5]).search_full_text(params[:query_text])
                else
                  Order.where(status: [3, 4, 5]).order(created_at: :desc)
                end
      @preparacion_count = @orders.count
    end

    def finalizadas
      @orders = if params[:query_text].present?
                  Order.where(status: [6, 7]).search_full_text(params[:query_text])
                else
                  Order.where(status: [6, 7]).order(created_at: :desc)
                end.page(params[:page]).per(20) # Paginación con 12 órdenes por página
      @finalizadas_count = @orders.total_count # Para contar todas las órdenes sin afectar la paginación
    end

    def cambiar_estado
      if Order.statuses.key?(params[:status])
        @order.update(status: params[:status])
        redirect_back fallback_location: admin_orders_path, notice: "Estado actualizado."
      else
        redirect_back fallback_location: admin_orders_path, alert: "Estado no válido."
      end
    end


    def show
    # Cargar datos relacionados
    @user = @order.user
    @address = @order.address
    @order_items = @order.order_items.includes(:product, :product_variant)
    @payment_method = @order.payment_method
    @shipping_method = @order.shipping_method
    end

    def destroy
      if @order.pendiente?
        @order.destroy
        redirect_to pendientes_admin_orders_path, notice: "Orden eliminada."
      else
        redirect_to admin_order_path(@order), alert: "No se puede eliminar la orden."
      end
    end


    def update
      if @order.update(order_params)
        redirect_to admin_order_path(@order), notice: "Orden actualizada correctamente."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def print
      @order = Order.find(params[:id])  # Encuentra la orden por ID
      @order_items = @order.order_items.includes(:product, :variant)  # Carga los ítems de la orden
      render layout: false  # No cargar el layout normal, solo el contenido de la vista de impresión
    end


    private

    def set_navbar_title
      @navbar_title = case action_name
                      when 'home' then "Panel de Órdenes"
                      when 'pendientes' then "Órdenes en Curso"
                      when 'pagos' then "Órdenes recientes"
                      when 'preparacion' then "Órdenes en Preparación"
                      when 'finalizadas' then "Órdenes Finalizadas"
                      when 'show' then "Detalle de la Orden"
                      else "Administración de Órdenes"
                      end
    end

    def set_order
      @order = Order.find(params[:id])
    end

    def set_orders_count
      @pendientes_count = Order.where(status: 0).count
      @pagos_count = Order.where(status: [1, 2]).count
      @preparacion_count = Order.where(status: 3).count
      @finalizadas_count = Order.where(status: [6, 7]).count
    end

    def order_params
      params.require(:order).permit(:status, :other_attributes_here)
    end
  end
end
