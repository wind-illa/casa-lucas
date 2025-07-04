# app/controllers/business/subcategories_controller.rb
module Business
  class SubcategoriesController < ApplicationController
    def index
    end

    def show
      @category = Category.find(params[:category_id])
      @subcategory = @category.subcategories.find(params[:id])
      @products = @subcategory.products.page(params[:page]).per(12)
    end
    
  end
end
