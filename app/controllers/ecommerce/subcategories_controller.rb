module Ecommerce
  class SubcategoriesController < ApplicationController
    before_action :set_category, only: [:index, :show]
    before_action :set_subcategory, only: [:show]

    # GET /ecommerce/categorias/:category_id/subcategorias
    # Muestra todas las subcategorías de una categoría específica
    def index
      @subcategories = @category.subcategories

      if @subcategories.empty?
        flash[:alert] = "No se encontraron subcategorías para esta categoría."
      end
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "La categoría especificada no existe."
      redirect_to ecommerce_categories_path
    end

    # GET /ecommerce/categorias/:category_id/subcategorias/:id
    # Muestra una subcategoría específica y los productos asociados
    def show
      @products = @subcategory.products

      if @products.empty?
        flash[:notice] = "No hay productos disponibles en esta subcategoría."
      end
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "La subcategoría especificada no existe."
      redirect_to ecommerce_category_subcategories_path(@category)
    end

    private

    # Método para obtener la categoría con el ID provisto en los parámetros
    def set_category
      @category = Category.find(params[:category_id])
    end

    # Método para obtener la subcategoría con el ID provisto en los parámetros
    def set_subcategory
      @subcategory = @category.subcategories.find(params[:id])
    end
  end
end
