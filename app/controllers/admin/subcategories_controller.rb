class Admin::SubcategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category
  before_action :set_navbar_title

  def index
    @subcategories = @category.subcategories
  end

  def new
    @subcategory = @category.subcategories.new
  end

  # def create
  #   @subcategory = @category.subcategories.new(subcategory_params)
  #   if @subcategory.save
  #     redirect_to admin_category_path(@category), notice: 'Subcategoría creada exitosamente.'
  #   else
  #     render :new
  #   end
  # end

  def create
    @subcategory = @category.subcategories.new(subcategory_params.except(:subcategory_image))

    if params[:subcategory][:subcategory_image].present?
      processed_image = ImageProcessing::MiniMagick
        .source(params[:subcategory][:subcategory_image])
        .resize_to_limit(1000, 1000)
        .convert("webp")
        .call

      @subcategory.subcategory_image.attach(
        io: processed_image,
        filename: "subcategory_image_#{SecureRandom.hex(4)}.webp",
        content_type: "image/webp"
      )
    end

    if @subcategory.save
      redirect_to admin_category_path(@category), notice: 'Subcategoría creada exitosamente.'
    else
      render :new
    end
  end


  def edit
    @category = Category.find(params[:category_id])
    @subcategory = @category.subcategories.find(params[:id])
  end

  # def update
  #   @category = Category.find(params[:category_id])
  #   @subcategory = @category.subcategories.find(params[:id])

  #   if @subcategory.update(subcategory_params)
  #     redirect_to admin_category_path(@category), notice: 'Subcategoría actualizada correctamente.'
  #   else
  #     render :edit
  #   end
  # end

  def update
    @category = Category.find(params[:category_id])
    @subcategory = @category.subcategories.find(params[:id])

    if params[:subcategory][:subcategory_image].present?
      # Eliminar imagen anterior si existe
      @subcategory.subcategory_image.purge if @subcategory.subcategory_image.attached?

      # Procesar la nueva imagen
      processed_image = ImageProcessing::MiniMagick
        .source(params[:subcategory][:subcategory_image])
        .resize_to_limit(800, 800)
        .convert("webp")
        .call

      @subcategory.subcategory_image.attach(
        io: processed_image,
        filename: "subcategory_image_#{SecureRandom.hex(4)}.webp",
        content_type: "image/webp"
      )
    end

    if @subcategory.update(subcategory_params.except(:subcategory_image))
      redirect_to admin_category_path(@category), notice: 'Subcategoría actualizada correctamente.'
    else
      render :edit
    end
  end


  def destroy
    @subcategory = @category.subcategories.find(params[:id])
    @subcategory.destroy
    redirect_to admin_category_path(@category), notice: 'Subcategoría eliminada exitosamente.'
  end

  private

  def subcategory_params
    params.require(:subcategory).permit(:subcategory_name, :category_id, :subcategory_image)  # Agrega :subcategory_photos
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_navbar_title
    case action_name
    when 'index'
      @navbar_title = "#{@category.category_name}"
    when 'new'
      @navbar_title = "#{@category.category_name}"
    when 'edit'
      @navbar_title = "#{@category.category_name}"
    when 'show'
      @navbar_title = "#{@category.category_name}"
    else
      @navbar_title = "Administración"
    end
  end
end
