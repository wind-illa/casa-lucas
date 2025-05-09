class Admin::BankAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bank_account, only: [:edit, :update, :destroy]
  before_action :set_navbar_title

  def index
    @bank_accounts = BankAccount.all
  end

  def new
    @bank_account = BankAccount.new
  end

  def edit
  end

  def create
    @bank_account = BankAccount.new(bank_account_params)

    if @bank_account.save
      # Solo desactivamos las otras cuentas si el estado de la nueva cuenta es 'activo'
      if @bank_account.estado == 'activo'
        BankAccount.where.not(id: @bank_account.id).update_all(estado: 'inactivo')
      end
      redirect_to admin_bank_accounts_path, notice: 'Cuenta bancaria creada correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end


  def update
    @bank_account = BankAccount.find(params[:id])

    if @bank_account.update(bank_account_params)
      # Si el estado de la cuenta es 'activo', desactivamos las otras cuentas
      if @bank_account.estado == 'activo'
        BankAccount.where.not(id: @bank_account.id).update_all(estado: 'inactivo')
      end
      redirect_to admin_bank_accounts_path, notice: 'Cuenta bancaria actualizada correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end



  def destroy
    @bank_account.destroy
    redirect_to admin_bank_accounts_path, notice: 'Cuenta bancaria eliminada correctamente.'
  end

  private

  def set_navbar_title
    @navbar_title = case action_name
                    when 'index' then "Cuentas Bancarias"
                    when 'new' then "Crear Cuenta Bancaria"
                    when 'edit' then "Editar Cuenta Bancaria"
                    when 'show' then "Configuración"
                    else "Inicio"
                    end
  end



  def set_bank_account
    @bank_account = BankAccount.find(params[:id])
  end

  def bank_account_params
    params.require(:bank_account).permit(:tipo, :numero, :account_number, :alias, :estado)
  end
end
