module Admin
  class ShippingMethodsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_shipping_method, only: [:edit, :update, :destroy]
    before_action :set_navbar_title

    # Index: Muestra todos los métodos de envío
    def index
      @shipping_methods = ShippingMethod.all
    end

    # New: Muestra el formulario para crear un nuevo método de envío
    def new
      @shipping_method = ShippingMethod.new
    end

    # Create: Crea un nuevo método de envío
    def create
      @shipping_method = ShippingMethod.new(shipping_method_params)

      if @shipping_method.save
        redirect_to admin_shipping_methods_path, notice: 'Método de envío creado exitosamente.'
      else
        render :new
      end
    end

    # Edit: Muestra el formulario para editar un método de envío existente
    def edit
    end

    # Update: Actualiza un método de envío existente
    def update
      if @shipping_method.update(shipping_method_params)
        redirect_to admin_shipping_methods_path, notice: 'Método de envío actualizado exitosamente.'
      else
        render :edit
      end
    end

    # Destroy: Elimina un método de envío
    def destroy
      @shipping_method.destroy
      redirect_to admin_shipping_methods_path, notice: 'Método de envío eliminado exitosamente.'
    end

    private

    # Setea el método de envío para las acciones de editar, actualizar y destruir
    def set_shipping_method
      @shipping_method = ShippingMethod.find(params[:id])
    end

    # Permite solo los parámetros seguros para un método de envío
    def shipping_method_params
      params.require(:shipping_method).permit(:name, :cost, :calculation_type, :description)
    end


    private


    def set_navbar_title
      @navbar_title = case action_name
                      when 'index' then "Métodos de Envío"
                      when 'new' then "Crear Método"
                      when 'edit' then "Editar Método"
                      else "Inicio"
                      end
    end


  end
end
