module Admin
  class PaymentMethodsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_payment_method, only: [:edit, :update, :destroy]
    before_action :set_navbar_title

    def index
      @payment_methods = PaymentMethod.all
    end

    def new
      @payment_method = PaymentMethod.new
    end

    def create
      @payment_method = PaymentMethod.new(payment_method_params)
      if @payment_method.save
        redirect_to admin_payment_methods_path, notice: 'Método de pago creado exitosamente.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @payment_method.update(payment_method_params)
        redirect_to admin_payment_methods_path, notice: 'Método de pago actualizado exitosamente.'
      else
        render :edit
      end
    end

    def destroy
      @payment_method.destroy
      redirect_to admin_payment_methods_path, notice: 'Método de pago eliminado exitosamente.'
    end

    private

    def set_navbar_title
      @navbar_title = case action_name
                      when 'index' then "Métodos de Pago"
                      when 'new' then "Crear Método de Pago"
                      when 'edit' then "Editar Método de Pago"
                      when 'show' then "Configuración"
                      else "Inicio"
                      end
    end


    def set_payment_method
      @payment_method = PaymentMethod.find(params[:id])
    end

    def payment_method_params
      params.require(:payment_method).permit(:name, :code, :description)
    end
  end
end
