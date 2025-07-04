# app/controllers/business/account/profiles_controller.rb
module Business
  module Account
    class ProfilesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user, only: [:show, :update, :update_profile_picture]

      def show
        # Vista del perfil del usuario
      end

      def informacion
        @user = current_user
      end

      def edit_name
        @user = current_user
      end

      def edit_email
        # Formulario para editar email
      end

      def edit_phone
        @user = current_user
      end

      def edit_dni
        @user = current_user
      end

      def fiscal_verification_form
        @user = current_user
      end

      def fiscal_verification_pending
        @user = current_user
      end

      def upload_constancia_fiscal
        @user = current_user

        if params[:user].present? && params[:user][:constancia_fiscal].present?
          archivo = params[:user][:constancia_fiscal]

          if archivo.content_type.start_with?("image/")
            processed_image = ImageProcessing::MiniMagick
                                .source(archivo)
                                .resize_to_limit(1000, 1000)
                                .convert("webp")
                                .call

            @user.constancia_fiscal.purge if @user.constancia_fiscal.attached?
            @user.constancia_fiscal.attach(
              io: processed_image,
              filename: "constancia_fiscal_#{@user.id}.webp",
              content_type: "image/webp"
            )

          elsif archivo.content_type == "application/pdf"
            @user.constancia_fiscal.purge if @user.constancia_fiscal.attached?
            @user.constancia_fiscal.attach(
              io: archivo.open,
              filename: archivo.original_filename,
              content_type: archivo.content_type
            )
          else
            redirect_to informacion_business_account_profile_path, alert: "Solo se permiten imágenes o PDF."
            return
          end
          # Redirigir a la vista de espera después de subir el archivo
          redirect_to fiscal_verification_pending_business_account_profile_path, notice: "Constancia enviada correctamente. Estamos verificando tus datos."
        else
          redirect_to informacion_business_account_profile_path, alert: "Debés subir un archivo válido."
        end
      end


      def update
        if @user.update(user_params)
          redirect_to informacion_business_account_profile_path, notice: build_success_message

        else
          flash.now[:alert] = 'Hubo un problema al actualizar el perfil.'
          render :edit_name  # Renderiza la vista de edición con errores
        end
      end

      def update_profile_picture
        if params[:user][:profile_picture].present?
          processed_image = ImageProcessing::MiniMagick
                              .source(params[:user][:profile_picture])
                              .resize_to_limit(600, 600)
                              .convert("webp")
                              .call

          @user.profile_picture.purge if @user.profile_picture.attached?
          @user.profile_picture.attach(
            io: processed_image,
            filename: "profile_picture_#{@user.id}.webp",
            content_type: "image/webp"
          )

          redirect_to business_account_profile_path, notice: 'Foto de perfil actualizada exitosamente.'
        else
          redirect_to business_account_profile_path, alert: "Debés seleccionar una imagen."
        end
      end


      private


      def build_success_message
        updated_fields = []

        updated_fields << "nombre" if @user.saved_change_to_first_name? || @user.saved_change_to_last_name?
        updated_fields << "teléfono" if @user.saved_change_to_phone?
        updated_fields << "DNI" if @user.saved_change_to_document_id? || @user.saved_change_to_document_type?

        if updated_fields.any?
          "#{updated_fields.join(' y ').capitalize} actualizado#{'s' if updated_fields.size > 1} exitosamente."
        else
          "Perfil actualizado exitosamente."
        end
      end

      def set_user
        @user = current_user
      end

      def profile_picture_params
        params.require(:user).permit(:profile_picture)
      end

      def constancia_fiscal_params
        params.require(:user).permit(:constancia_fiscal)
      end


      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :phone, :document_type, :document_id)
      end
    end
  end
end
