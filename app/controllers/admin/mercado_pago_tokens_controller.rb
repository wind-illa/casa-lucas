class Admin::MercadoPagoTokensController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mercado_pago_token, only: [:edit, :update, :destroy]
  before_action :set_navbar_title



  def index
    @mercado_pago_tokens = MercadoPagoToken.all
  end

  def new
    @mercado_pago_token = MercadoPagoToken.new
  end

  def create
    @mercado_pago_token = MercadoPagoToken.new(mercado_pago_token_params)

    if @mercado_pago_token.save
      # Solo desactivamos los otros tokens si el estado del nuevo token es 'activo'
      if @mercado_pago_token.estado == 'activo'
        MercadoPagoToken.where.not(id: @mercado_pago_token.id).update_all(estado: 'inactivo')
      end
      redirect_to admin_mercado_pago_tokens_path, notice: 'Token creado correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @mercado_pago_token = MercadoPagoToken.find(params[:id])

    if @mercado_pago_token.update(mercado_pago_token_params)
      # Si el estado cambia a 'activo', desactivamos los otros tokens
      if @mercado_pago_token.estado == 'activo'
        MercadoPagoToken.where.not(id: @mercado_pago_token.id).update_all(estado: 'inactivo')
      end
      redirect_to admin_mercado_pago_tokens_path, notice: 'Token actualizado correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @mercado_pago_token.destroy
    redirect_to admin_mercado_pago_tokens_path, notice: 'Token eliminado correctamente.'
  end

  private

  def set_navbar_title
    @navbar_title = case action_name
                    when 'index'
                      "Tokens de Mercado Pago"
                    when 'new'
                      "Nuevo token"
                    when 'edit'
                      "Editar token"
                    else
                      "Administración de Tokens de Mercado Pago"
                    end
  end

  def set_mercado_pago_token
    @mercado_pago_token = MercadoPagoToken.find(params[:id])
  end

  def mercado_pago_token_params
    params.require(:mercado_pago_token).permit(:token, :estado, :nombre)
  end
end
