class Admin::ProductVariantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_product_variant, only: [:edit, :update, :destroy]

  def new
    @product_variant = @product.product_variants.build
  end

  # def create
  #   @product_variant = @product.product_variants.build(product_variant_params)
  #   if @product_variant.save
  #     redirect_to admin_product_path(@product), notice: "Variante creada con éxito."
  #   else
  #     flash[:alert] = "Hubo un error al crear la variante."
  #     render :new, status: :unprocessable_entity
  #   end
  # end

  def create
    @product_variant = @product.product_variants.build(product_variant_params.except(:images))

    if params[:product_variant][:images]
      processed_files = []

      params[:product_variant][:images].reject(&:blank?).each_with_index do |image, index|
        processed_image = ImageProcessing::MiniMagick
          .source(image)
          .resize_to_limit(1200, 1200)
          .convert("webp")
          .call

        processed_files << {
          io: processed_image,
          filename: "variante_imagen_#{index + 1}.webp",
          content_type: "image/webp"
        }
      end

      processed_files.each do |file|
        @product_variant.images.attach(file)
      end
    end

    if @product_variant.save
      redirect_to admin_product_path(@product), notice: "Variante creada con éxito."
    else
      flash[:alert] = "Hubo un error al crear la variante."
      render :new, status: :unprocessable_entity
    end
  end


  def edit
  end

  # def update
  #   # Eliminar imágenes seleccionadas
  #   if params[:product_variant][:images_to_remove].present?
  #     params[:product_variant][:images_to_remove].each do |image_id|
  #       image = @product_variant.images.find(image_id)
  #       image.purge # Elimina la imagen de Active Storage/Cloudinary
  #     end
  #   end

  #   # Adjuntar nuevas imágenes
  #   if params[:product_variant][:images].present?
  #     @product_variant.images.attach(params[:product_variant][:images])
  #   end

  #   # Actualizar el resto de los atributos
  #   if @product_variant.update(product_variant_params.except(:images, :images_to_remove))
  #     redirect_to admin_product_path(@product), notice: "Variante actualizada con éxito."
  #   else
  #     flash[:alert] = "Hubo un error al actualizar la variante."
  #     render :edit, status: :unprocessable_entity
  #   end
  # end

  def update
    # Eliminar imágenes seleccionadas
    if params[:product_variant][:images_to_remove].present?
      params[:product_variant][:images_to_remove].each do |image_id|
        image = @product_variant.images.find(image_id)
        image.purge
      end
    end

    # Adjuntar nuevas imágenes procesadas
    if params[:product_variant][:images].present?
      processed_files = []

      params[:product_variant][:images].reject(&:blank?).each_with_index do |image, index|
        processed_image = ImageProcessing::MiniMagick
          .source(image)
          .resize_to_limit(1200, 1200)
          .convert("webp")
          .call

        processed_files << {
          io: processed_image,
          filename: "variante_update_#{index + 1}.webp",
          content_type: "image/webp"
        }
      end

      processed_files.each do |file|
        @product_variant.images.attach(file)
      end
    end

    if @product_variant.update(product_variant_params.except(:images, :images_to_remove))
      redirect_to admin_product_path(@product), notice: "Variante actualizada con éxito."
    else
      flash[:alert] = "Hubo un error al actualizar la variante."
      render :edit, status: :unprocessable_entity
    end
  end



  def destroy
    @product_variant.destroy
    redirect_to admin_product_path(@product), notice: "Variante eliminada con éxito."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end


  def set_product_variant
    @product_variant = @product.product_variants.find(params[:id])
  end

  def product_variant_params
    params.require(:product_variant).permit(
      :color,
      images: [])
  end

end
