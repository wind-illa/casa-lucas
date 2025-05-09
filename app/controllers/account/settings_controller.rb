class Account::SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    # Vista de ajustes
  end

  def delete_account
    # current_user.purchases.destroy_all    # Elimina todas las compras del usuario
    current_user.destroy
    redirect_to root_path, notice: 'Tu cuenta ha sido eliminada.'
  end
end
