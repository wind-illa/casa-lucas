module Ecommerce
  class ProductsController < ApplicationController
    before_action :set_category, only: [:index,]
    before_action :set_subcategory, only: [:index]


    def index
      @category = Category.find(params[:category_id])
      @subcategory = Subcategory.find(params[:subcategory_id])
      # Orden predeterminado por los más nuevos primero
      @products = @subcategory.products.order(created_at: :desc).page(params[:page]).per(10)

      # Manejo de filtros
      if params[:sort].present?
        case params[:sort]
        when 'asc'
          @products = @products.reorder(price: :asc)
        when 'desc'
          @products = @products.reorder(price: :desc)
        when 'newest'
          @products = @products.reorder(created_at: :desc)
        end
      end
    end


    def pagos
      @orders = if params[:query_text].present?
                  Order.where(status: [1, 2]).search_full_text(params[:query_text])
                else
                  Order.where(status: [1, 2]).order(created_at: :desc)
                end
      @pagos_count = @orders.count
    end


    def search
      # Si hay un texto de búsqueda, filtra los productos
      @products = Product.search_full_text(params[:query_text]) if params[:query_text].present?

      # Si no hay texto de búsqueda, solo obtenemos todos los productos
      @products ||= Product.all

      # Ordenamos por fecha de creación
      @products = @products.order(created_at: :desc)

      # Incluir las imágenes adjuntas y las asociaciones de categoría y subcategoría (si es necesario)
      @products = @products.with_attached_product_images.includes(:category, :subcategory)

      # Cargar todas las categorías y subcategorías
      @categories = Category.includes(:subcategories).all

      # Paginamos los resultados (por ejemplo, 12 productos por página)
      @products = @products.page(params[:page]).per(12)

      # Si no hay productos, muestra un mensaje
      if @products.blank?
        flash[:notice] = "No se encontraron productos para la búsqueda '#{params[:query_text]}'."
      end
    end




    def super_offers
      # Carga las categorías con subcategorías de forma eficiente
      @categories = Category.includes(:subcategories)
      # Limita los productos a aquellos con super ofertas, aplica paginación
      @products = Product.super_offers.page(params[:page]).per(12)
    end




    def new_arrivals
      # Carga las categorías con sus subcategorías
      @categories = Category.includes(:subcategories)
      # Carga los últimos 50 productos, sin intentar cargar imágenes de forma explícita
      @products = Product.new_arrivals.limit(50).page(params[:page]).per(20)
    end





    def best_sellers
      @products = Product.best_sellers
      @categories = Category.includes(:subcategories)
    end



    def history
      if user_signed_in?
        @history_products = current_user.histories.includes(:product).order(created_at: :desc).limit(50).map(&:product)
      else
        @history_products = Product.find(session[:history] || [])
      end
    end




    def clear_history
      if user_signed_in?
        current_user.histories.destroy_all # Para usuarios logueados, eliminamos los registros de la tabla histories
      else
        session.delete(:history) # Para usuarios no logueados, limpiamos el historial guardado en la sesión
      end
      redirect_to ecommerce_history_path, notice: 'Tu historial ha sido limpiado.' # Redirigimos al historial después de eliminarlo
    end



    def remove_from_history
      product_id = params[:id]

      if user_signed_in?
        history = current_user.histories.find_by(product_id: product_id) # Usuarios registrados: eliminamos el producto específico de la tabla histories
        if history
          history.destroy
          notice_message = 'Producto eliminado del historial.'
        else
          notice_message = 'El producto no se encontró en tu historial.'
        end
      else
        session[:history] ||= []    # Usuarios no registrados: eliminamos el producto del historial guardado en la sesión
        if session[:history].include?(product_id.to_i)
          session[:history].delete(product_id.to_i)
          notice_message = 'Producto eliminado del historial.'
        else
          notice_message = 'El producto no se encontró en tu historial.'
        end
      end
      redirect_to ecommerce_history_path, notice: notice_message
    end



    def show
      @product = Product.find(params[:id])
      @product_variants = @product.product_variants # Cargar las variantes

      if user_signed_in?
        # Primero asigna el carrito y luego usa sus métodos
        @cart = current_user.cart
        @cart_items = @cart.cart_items.includes(product: :product_variants).order(id: :desc)
      end

      # Productos relacionados basados en la subcategoría del producto actual
      @related_products = Product.where(subcategory: @product.subcategory)
                                  .where.not(id: @product.id)
                                  .limit(4)

      # Cargar la categoría y subcategoría relacionadas con el producto
      @category = @product.category
      @subcategory = @product.subcategory

      # Determinar la variante seleccionada (si corresponde)
      @selected_variant = @product.product_variants.find_by(id: params[:variant_id])

      if user_signed_in?
        # Buscar el elemento del carrito relacionado con este producto y variante
        if @selected_variant
          @cart_item = @cart.cart_items.find_by(product_id: @product.id, variant_id: @selected_variant.id)
        else
          @cart_item = @cart.cart_items.find_by(product_id: @product.id)
        end
      end

      # Guardar el historial de navegación
      if user_signed_in?
        history = History.find_or_create_by(user_id: current_user.id, product_id: @product.id)
        if current_user.histories.count > 50
          current_user.histories.order(:created_at).first.destroy
        end
      else
        session[:history] ||= []
        unless session[:history].include?(@product.id)
          session[:history].shift if session[:history].size >= 50
          session[:history] << @product.id
        end
      end
    end












    private

    # Configura la categoría seleccionada (si existe)
    def set_category
      @category = Category.find(params[:category_id]) if params[:category_id].present?
    end

    # Configura la subcategoría seleccionada (si existe)
    def set_subcategory
      @subcategory = Subcategory.find(params[:subcategory_id]) if params[:subcategory_id].present?
    end

    # Aplica filtros a los productos
    def filter_products
      # Filtro por nombre de producto
      if params[:search].present?
        @products = @products.where("name LIKE ?", "%#{params[:search]}%")
      end

      # Filtro por marca
      if params[:brand].present?
        @products = @products.where(brand: params[:brand])
      end

      # Filtro por rango de precio
      if params[:min_price].present? && params[:max_price].present?
        @products = @products.where(price: params[:min_price]..params[:max_price])
      elsif params[:min_price].present?
        @products = @products.where("price >= ?", params[:min_price])
      elsif params[:max_price].present?
        @products = @products.where("price <= ?", params[:max_price])
      end

      # Filtro por disponibilidad (si solo queremos mostrar productos en stock)
      if params[:in_stock].present? && params[:in_stock] == 'true'
        @products = @products.where("stock > ?", 0)
      end
    end

    # Ordena los productos de acuerdo a los parámetros de ordenamiento
    def sort_products
      case params[:sort_by]
      when 'price_asc'
        @products = @products.order(price: :asc)
      when 'price_desc'
        @products = @products.order(price: :desc)
      when 'newest'
        @products = @products.order(created_at: :desc)
      when 'popular'
        # Ejemplo para ordenar por popularidad (necesitarías un campo de `sales_count` o similar en el modelo Product)
        @products = @products.order(sales_count: :desc)
      else
        @products = @products.order(name: :asc) # Orden por defecto, alfabético
      end
    end


  end
end
