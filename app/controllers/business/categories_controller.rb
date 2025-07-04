# app/controllers/business/categories_controller.rb
module Business
  class CategoriesController < ApplicationController
    before_action :set_category, only: :show

    # Muestra todas las categorías, con opción de paginación y ordenamiento
    def index
      @categories = Category.all.order(:category_name).page(params[:page]).per(10)
    end

    # Muestra una categoría específica con sus subcategorías y productos
    def show
      # Carga las subcategorías de la categoría seleccionada y realiza pre-carga de los productos
      @subcategories = @category.subcategories.includes(:products)

      # Opcional: filtro de productos por subcategoría o por atributos de producto
      if params[:subcategory_id].present?
        @products = Product.where(subcategory_id: params[:subcategory_id]).order(:name)
      else
        @products = Product.where(subcategory: @subcategories).order(:name)
      end

      # Paginación para los productos en la categoría o subcategoría seleccionada
      @products = @products.page(params[:page]).per(12)
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "La categoría solicitada no existe."
      redirect_to ecommerce_categories_path
    end

    private

    # Configura la categoría basada en el ID proporcionado
    def set_category
      @category = Category.find(params[:id])
    end
  end
end
