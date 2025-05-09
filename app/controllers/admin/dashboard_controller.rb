class Admin::DashboardController < ApplicationController
  before_action :authenticate_user! # Asegúrate de que el usuario esté autenticado

  def index
    @total_products = Product.count
    @total_categories = Category.count
    @total_subcategories = Subcategory.count
    @total_users = User.count
    # Aquí puedes agregar estadísticas o información de la tienda
  end
end
