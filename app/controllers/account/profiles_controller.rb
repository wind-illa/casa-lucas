class Account::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :update, :update_profile_picture]

  def show
    # Vista del perfil del usuario
  end

  def information
    # Vista de información personal
  end

  def edit_name
    # Formulario para editar nombre
  end

  def edit_email
    # Formulario para editar email
  end

  def edit_phone
    # Formulario para editar teléfono
  end

  def edit_dni
    @user = current_user
  end


  def update
    if @user.update(user_params)
      redirect_to information_account_profiles_path(@user), notice: 'Perfil actualizado exitosamente.'
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

      redirect_to account_profile_path(@user), notice: 'Foto de perfil actualizada exitosamente.'
    else
      redirect_to account_profile_path(@user), alert: "Debés seleccionar una imagen."
    end
  end


  private

  def set_user
    @user = current_user
  end

  def profile_picture_params
    params.require(:user).permit(:profile_picture)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :document_type, :document_id)
  end

end
