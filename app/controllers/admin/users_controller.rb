class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy]
  before_action :set_navbar_title

  def clientes
    @users = User.includes(:addresses).where(role: :cliente)
    @users = @users.search_full_text(params[:query_text]) if params[:query_text].present?
    @users = @users.order(created_at: :desc)
    @users = @users.page(params[:page]).per(20)
  end

  def admins
    @users = User.includes(:addresses).where(role: [:administrador, :repositor, :cajero])
    @users = @users.search_full_text(params[:query_text]) if params[:query_text].present?
    @users = @users.order(created_at: :desc)
    @users = @users.page(params[:page]).per(20)
  end



  def show; end

  def new
    @user = User.new
  end

  # def create
  #   @user = User.new(user_params)
  #   if @user.save
  #     redirect_to clientes_admin_users_path, notice: 'Usuario creado exitosamente.'
  #   else
  #     render :new, status: :unprocessable_entity
  #   end
  # end

  def create
    @user = User.new(user_params.except(:profile_picture))

    if params[:user][:profile_picture].present?
      processed_image = ImageProcessing::MiniMagick
        .source(params[:user][:profile_picture])
        .resize_to_limit(500, 500)
        .convert("webp")
        .call

      @user.profile_picture.attach(
        io: processed_image,
        filename: "profile_picture_#{SecureRandom.hex(4)}.webp",
        content_type: "image/webp"
      )
    end

    if @user.save
      redirect_to clientes_admin_users_path, notice: 'Usuario creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit; end

  # def update
  #   if @user.update(user_params)
  #     redirect_to clientes_admin_users_path, notice: 'Usuario actualizado exitosamente.'
  #   else
  #     render :edit, status: :unprocessable_entity # 👈 Esto le dice a Turbo que renderice correctamente
  #   end
  # end
  
  def update
    # Procesar nueva imagen si se cargó
    if params[:user][:profile_picture].present?
      # Eliminar la imagen anterior si existía
      @user.profile_picture.purge if @user.profile_picture.attached?

      # Procesar y convertir la nueva imagen
      processed_image = ImageProcessing::MiniMagick
        .source(params[:user][:profile_picture])
        .resize_to_limit(500, 500)
        .convert("webp")
        .call

      # Adjuntar la imagen procesada
      @user.profile_picture.attach(
        io: processed_image,
        filename: "profile_picture_#{SecureRandom.hex(4)}.webp",
        content_type: "image/webp"
      )
    end

    # Actualizar los demás datos
    if @user.update(user_params.except(:profile_picture))
      redirect_to clientes_admin_users_path, notice: 'Usuario actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @user.destroy
    redirect_to clientes_admin_users_path, notice: 'Usuario eliminado exitosamente.'
  end

  private

  def set_navbar_title
    @navbar_title = case action_name
                    when 'clientes'
                      "Listado de Clientes"
                    when 'admins'
                      "Listados de Operadores"
                    when 'new'
                      "Nuevo Usuario"
                    when 'edit'
                      "Editar Usuario"
                    when 'show'
                      "Perfil del Usuario"
                    else
                      "Administración de Usuarios"
                    end
  end


  def set_user
    @user = User.find(params[:id])
    @orders = @user.orders.order(created_at: :desc).page(params[:page]).per(10)
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :password, :password_confirmation,
      :document_id, :phone, :role, :profile_picture, :document_type,
      addresses_attributes: %i[id street_name street_number floor apartment locality city province_code postal_code indications _destroy]
    ).tap do |whitelisted|
      whitelisted[:document_type] = User.document_types.key(params[:user][:document_type].to_i) if params[:user][:document_type].present?
      whitelisted[:role] = User.roles.key(params[:user][:role].to_i) if params[:user][:role].present?
    end
  end



end
