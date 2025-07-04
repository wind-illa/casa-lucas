# app/controllers/business/home_controller.rb
module Business
  class HomeController < ApplicationController
    def index
      @banners = Banner.all
      @categories = Category.all

      # Cargar las subcategorías relacionadas con cada categoría
      @categories = Category.includes(:subcategories)

      # Cargar productos destacados, más vendidos o recientes
      @novedades = Product.order(created_at: :desc).limit(4)
      @mas_vendidos = Product.best_sellers.limit(4)
      @destacados = Product.where(destacado: true).limit(4)

      # Traer productos con descuento (ofertas)
      @ofertas = Product.where("price_discount > 0").order(price_discount: :desc).limit(4)

      # Cargar los últimos 4 productos del historial
      @history_products = get_history_products

      # Cargar el historial completo limitado a 24 productos
      @full_history = get_full_history

      # Cargar todas las subcategorías
      @all_subcategories = Subcategory.all
    end

        private

     # Método para obtener el historial completo de navegación (máximo 24 productos)
    def get_full_history
      if user_signed_in?
        current_user.histories.includes(:product).order(created_at: :desc).limit(24).map(&:product)
      else
        Product.find(Array(session[:history]).last(24) || [])
      end
    end

    # Método para obtener los productos del historial
    def get_history_products
      if user_signed_in?
        current_user.histories.includes(:product).order(created_at: :desc).limit(4).map(&:product)
      else
        history_ids = session[:history].to_a.last(4)
        Product.where(id: history_ids).to_a
      end
    end

  end
end
