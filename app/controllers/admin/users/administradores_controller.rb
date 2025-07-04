module Admin
  module Users
    class AdministradoresController < ApplicationController
      before_action :authenticate_user!
      before_action :set_administrador, only: [:show, :edit, :update, :destroy, :toggle_status]

      def index
        @administradores = User.administrador.order(created_at: :desc)

        if params[:query_text].present?
          @administradores = @administradores.merge(
            User.search_full_text(params[:query_text])
          )
        end

        per_page = params[:per_page]&.to_i
        per_page = 10 unless per_page&.positive?  # Default 12 si no viene o es inválido

        @administradores = @administradores.page(params[:page]).per(per_page)
      end

      def new
        @administrador = User.new(document_type: :DNI)
      end

      def create
        @administrador = User.new(administrador_params.except(:profile_picture))
        @administrador.role = :administrador

        if params[:user][:profile_picture].present?
          processed_image = ImageProcessing::MiniMagick
            .source(params[:user][:profile_picture])
            .resize_to_fill(200, 200) # Recorta exactamente a 200x200
            .convert("webp")
            .call

          @administrador.profile_picture.attach(
            io: processed_image,
            filename: "admin_profile_#{SecureRandom.hex(4)}.webp",
            content_type: "image/webp"
          )
        end

        if @administrador.save
          redirect_to admin_users_administradores_path, notice: "Administrador creado correctamente."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def show; end

      def edit; end

      def update
        user_params = administrador_params

        if params[:user][:profile_picture].present?
          processed_image = ImageProcessing::MiniMagick
            .source(params[:user][:profile_picture])
            .resize_to_fill(200, 200)
            .convert("webp")
            .call

          @administrador.profile_picture.purge if @administrador.profile_picture.attached?

          @administrador.profile_picture.attach(
            io: processed_image,
            filename: "admin_profile_#{SecureRandom.hex(4)}.webp",
            content_type: "image/webp"
          )
        end

        password = user_params[:password]
        password_confirmation = user_params[:password_confirmation]

        # Si ambos vacíos, ignorar
        if password.blank? && password_confirmation.blank?
          user_params = user_params.except(:password, :password_confirmation)

        # Si solo password tiene valor y confirmación está vacía → ignorar (no actualizar contraseña)
        elsif password.present? && password_confirmation.blank?
          user_params = user_params.except(:password, :password_confirmation)

        # Si ambos tienen valor y no coinciden → error
        elsif password.present? && password_confirmation.present? && password != password_confirmation
          @administrador.errors.add(:password_confirmation, "no coincide con la contraseña")
          return render :edit, status: :unprocessable_entity
        end

        if @administrador.update(user_params.except(:profile_picture))
          redirect_to admin_users_administradores_path, notice: "Administrador actualizado correctamente."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @administrador.destroy
        redirect_to admin_users_administradores_path, notice: "Administrador eliminado correctamente."
      end

      def toggle_status
        @administrador.status = @administrador.habilitado? ? :inhabilitado : :habilitado

        if @administrador.save
          estado = @administrador.habilitado? ? "habilitado" : "inhabilitado"
          nombre = @administrador.first_name.capitalize || @administrador.email
          redirect_to admin_users_administradores_path, notice: "#{nombre} fue #{estado} como administrador."
        else
          redirect_to admin_users_administradores_path, alert: "No se pudo actualizar el estado del usuario."
        end
      end

      private

      def set_administrador
        @administrador = User.administrador.find(params[:id])
      end

      def administrador_params
        attrs = params.require(:user).permit(
          :first_name, :last_name, :email,
          :password, :password_confirmation,
          :phone, :document_type, :document_id,
          :profile_picture
        )

        # Eliminar el tipo de documento si no se ingresó número
        attrs.delete(:document_type) if attrs[:document_id].blank?

        attrs
      end
    end
  end
end
