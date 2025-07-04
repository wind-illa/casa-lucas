# app/controllers/business/account/settings_controller.rb
module Business
  module Account
    class SettingsController < ApplicationController
      before_action :authenticate_user!

      def show
        @user = current_user
      end

      def edit_password
        @user = current_user
      end

      def update_password
        @user = current_user
        if @user.update(password_params)
          # Cerrar sesión manualmente:
          sign_out(@user)

          # Redirigir al login con mensaje custom:
          redirect_to new_user_session_path, alert: 'Tu contraseña fue actualizada. Por favor, inicia sesión nuevamente.'
        else
          flash.now[:alert] = 'No se pudo actualizar la contraseña.'
          render :edit_password, status: :unprocessable_entity
        end
      end


      def edit_email
        @user = current_user
      end

      def update_email
        @user = current_user
        if @user.update(email_params)
          redirect_to business_account_settings_path, notice: '¡Todo en orden! Hemos actualizado tu correo electrónico con éxito.'
        else
          flash.now[:alert] = 'No se pudo actualizar el email.'
          render :edit_email
        end
      end

      def delete_account
        current_user.destroy
        redirect_to root_path, notice: 'Tu cuenta fue eliminada correctamente.'
      end

      private

      def password_params
        params.require(:user).permit(:password, :password_confirmation)
      end

      def email_params
        params.require(:user).permit(:email)
      end
    end
  end
end
