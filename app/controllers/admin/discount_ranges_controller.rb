class Admin::DiscountRangesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discount_range, only: [:edit, :update, :destroy]
  before_action :set_navbar_title

  def index
    @discount_ranges = DiscountRange.order(min_amount: :asc)
  end


  def new
    @discount_range = DiscountRange.new
  end

  def create
    @discount_range = DiscountRange.new(discount_range_params)
    if @discount_range.save
      redirect_to admin_discount_ranges_path, notice: 'Rango de descuento creado con éxito.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @discount_range.update(discount_range_params)
      redirect_to admin_discount_ranges_path, notice: 'Rango de descuento actualizado con éxito.'
    else
      render :edit
    end
  end

  def destroy
    @discount_range.destroy
    redirect_to admin_discount_ranges_path, notice: 'Rango de descuento eliminado con éxito.'
  end

  private

  def set_navbar_title
    @navbar_title = case action_name
                    when 'index' then "Rangos de Descuento"
                    when 'new' then "Crear Nuevo Rango"
                    when 'edit' then "Editar el Rango"
                    else "Inicio"
                    end
  end


  def set_discount_range
    @discount_range = DiscountRange.find(params[:id])
  end

  def discount_range_params
    params.require(:discount_range).permit(:min_amount, :discount_percentage)
  end
end
