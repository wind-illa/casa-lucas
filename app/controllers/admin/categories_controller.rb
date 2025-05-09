# app/controllers/admin/categories_controller.rb
class Admin::CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_navbar_title
  before_action :set_category, only: [:edit, :update, :destroy, :show]





  def index
    if params[:query_text].present?
      @categories = Category.search_full_text(params[:query_text])
    else
      # Si no hay texto de búsqueda, se muestran todas las categorías
      @categories = Category.all
    end
  end





  def new
    @category = Category.new
  end

  # def create
  #   @category = Category.new(category_params)
  #   if @category.save
  #     redirect_to admin_categories_path, notice: 'Categoría creada exitosamente.'
  #   else
  #     flash.now[:alert] = "Hubo un problema al crear la categoría."
  #     render :new
  #   end
  # end

  def create
    @category = Category.new(category_params.except(:category_image))

    if params[:category][:category_image].present?
      processed_image = ImageProcessing::MiniMagick
        .source(params[:category][:category_image])
        .resize_to_limit(1000, 1000)
        .convert("webp")
        .call

      @category.category_image.attach(
        io: processed_image,
        filename: "category_image_#{SecureRandom.hex(4)}.webp",
        content_type: "image/webp"
      )
    end

    if @category.save
      redirect_to admin_categories_path, notice: 'Categoría creada exitosamente.'
    else
      flash.now[:alert] = "Hubo un problema al crear la categoría."
      render :new
    end
  end


  def edit
    @category = Category.find(params[:id])
  end


  # def update
  #   if @category.update(category_params)
  #     redirect_to admin_categories_path, notice: 'Categoría actualizada exitosamente.'
  #   else
  #     flash.now[:alert] = "Hubo un problema al actualizar la categoría."
  #     render :edit
  #   end
  # end

  def update
    # Procesamos la imagen si se subió una nueva
    if params[:category][:category_image].present?
      # Eliminamos la imagen anterior si existe
      @category.category_image.purge if @category.category_image.attached?

      # Procesamos la nueva imagen
      processed_image = ImageProcessing::MiniMagick
        .source(params[:category][:category_image])
        .resize_to_limit(1000, 1000)
        .convert("webp")
        .call

      @category.category_image.attach(
        io: processed_image,
        filename: "category_image_#{SecureRandom.hex(4)}.webp",
        content_type: "image/webp"
      )
    end

    # Actualizamos el resto de los atributos (sin la imagen original)
    if @category.update(category_params.except(:category_image))
      redirect_to admin_categories_path, notice: 'Categoría actualizada exitosamente.'
    else
      flash.now[:alert] = "Hubo un problema al actualizar la categoría."
      render :edit
    end
  end


  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: 'Categoría eliminada exitosamente.'
    else
      redirect_to admin_categories_path, alert: 'Hubo un error al eliminar la categoría.'
    end
  end

  def show
    @category = Category.find(params[:id]) # Asegúrate de que estás obteniendo correctamente la categoría.

    if params[:query_text].present?
      # Si hay texto de búsqueda, se filtran las subcategorías utilizando `search_full_text`
      @subcategories = @category.subcategories.search_full_text(params[:query_text])
    else
      # Si no hay texto de búsqueda, se muestran todas las subcategorías
      @subcategories = @category.subcategories
    end
  end


  private

  def category_params
    params.require(:category).permit(:category_name, :category_image)  # Permite category_image para archivos adjuntos
  end

  def set_category
    @category = Category.find_by(id: params[:id])
    unless @category
      redirect_to admin_categories_path, alert: 'Categoría no encontrada.'
    end
  end

  def set_navbar_title
    case action_name
    when 'index'
      @navbar_title = "Categorías"
    when 'new'
      @navbar_title = "Nueva Categoría"
    when 'edit'
      @navbar_title = "Editar Categoría"
    when 'show'
      @navbar_title = "#{Category.find(params[:id]).category_name}"
    else
      @navbar_title = "Administración"
    end
  end
end
