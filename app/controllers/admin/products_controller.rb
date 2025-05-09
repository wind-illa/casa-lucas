
class Admin::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_categories, only: [:new, :create,]
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_navbar_title


  def index
    # Iniciamos la consulta base
    @products = Product.with_attached_product_images.includes(:category, :subcategory)

    # Filtro por texto de búsqueda
    @products = @products.search_full_text(params[:query_text]) if params[:query_text].present?

    # Filtro por subcategoría
    @products = @products.where(subcategory_id: params[:subcategory_id]) if params[:subcategory_id].present?

    # Filtro por estado de stock
    if params[:stock_status].present?
      case params[:stock_status]
      when "in_stock"
        @products = @products.where("stock_quantity > ?", 10)
      when "low_stock"
        @products = @products.where("stock_quantity > 0 AND stock_quantity <= ?", 10)
      when "out_of_stock"
        @products = @products.where(stock_quantity: 0)
      end
    end

    # Ordenamos y paginamos al final
    per_page = params[:per_page] || 20  # Usamos 10 como valor predeterminado
    @products = @products.order(created_at: :desc).page(params[:page]).per(per_page)
  end

  def show
    @product_variants = @product.product_variants.includes(images_attachments: :blob)
  end

  def new
    @product = Product.new
    @product.generate_unique_sku # Llama al método para generar el SKU sin guardar
    @subcategories = []  # Vaciar subcategorías cuando se crea un nuevo producto
    @product.bar_codes.build # Añadir un código de barra inicial vacío
  end

  def edit
    @categories = Category.all
    @product.bar_codes.build if @product.bar_codes.empty?

  end

  # def update
  #   @product = Product.find(params[:id])

  #   # Si el parámetro contiene imágenes para eliminar, las procesamos
  #   if params[:product][:product_images_attributes]
  #     params[:product][:product_images_attributes].each do |index, attributes|
  #       if attributes[:_destroy] == 'true'
  #         image = @product.product_images.find(attributes[:id])
  #         image.purge # Eliminar la imagen de Cloudinary
  #       end
  #     end
  #   end

  #   # Si hay nuevas imágenes, las adjuntamos
  #   if params[:product][:product_images].present?
  #     @product.product_images.attach(params[:product][:product_images])
  #   end

  #   # Actualizar el producto con los demás parámetros
  #   if @product.update(product_params.except(:product_images))
  #     redirect_to admin_products_path, notice: 'Producto actualizado exitosamente'
  #   else
  #     render :edit
  #   end
  # end

  def update
    @product = Product.find(params[:id])

    # Eliminar imágenes marcadas para destruir
    if params[:product][:product_images_attributes]
      params[:product][:product_images_attributes].each do |index, attributes|
        if attributes[:_destroy] == 'true'
          image = @product.product_images.find(attributes[:id])
          image.purge
        end
      end
    end

    # Procesar y adjuntar nuevas imágenes si hay
    if params[:product][:product_images].present?
      processed_files = []

      params[:product][:product_images].reject(&:blank?).each_with_index do |image, index|
        processed_image = ImageProcessing::MiniMagick
          .source(image)
          .resize_to_limit(1200, 1200)
          .convert("webp")
          .call

        processed_files << {
          io: processed_image,
          filename: "imagen_#{index + 1}.webp",
          content_type: "image/webp"
        }
      end

      processed_files.each do |file|
        @product.product_images.attach(file)
      end
    end

    # Actualizar los demás atributos
    if @product.update(product_params.except(:product_images))
      redirect_to admin_products_path, notice: 'Producto actualizado exitosamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end




  def destroy

    if @product.destroy
      redirect_to admin_products_path, notice: 'Producto eliminado con éxito.'
    else
      redirect_to admin_products_path, alert: 'Hubo un error al eliminar el producto.'
    end
  end

  # def create
  #   @product = Product.new(product_params)
  #   # logger.debug "PARAMS: #{product_params}"
  #   if @product.save
  #     puts @product.bar_codes.count
  #     redirect_to admin_products_path, notice: "Producto creado correctamente."
  #   else
  #     render :new, status: :unprocessable_entity
  #   end
  # end
  def create
    @product = Product.new(product_params.except(:product_images))

    if params[:product][:product_images]
      processed_files = []

      params[:product][:product_images].reject(&:blank?).each_with_index do |image, index|

        processed_image = ImageProcessing::MiniMagick
          .source(image)
          .resize_to_limit(1200, 1200)
          .convert("webp")
          .call

        processed_files << {
          io: processed_image,
          filename: "imagen_#{index + 1}.webp",
          content_type: "image/webp"
        }
      end

      # Adjuntamos todas las imágenes procesadas
      processed_files.each do |file|
        @product.product_images.attach(file)
      end
    end

    if @product.save
      puts @product.bar_codes.count
      redirect_to admin_products_path, notice: "Producto creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def load_subcategories
    category_id = params[:category_id]
    @subcategories = Subcategory.where(category_id: category_id)
    render json: @subcategories
  end

  private   #--------------------------------------------------------------

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_products_path, alert: "Producto no encontrado"
  end

  def set_categories
    @categories = Category.all
  end

  def set_navbar_title
  @navbar_title = case action_name
                  when 'index' then "Productos"
                  when 'new' then "Nuevo Producto"
                  when 'edit' then "Editar Producto"
                  when 'show' then @product.product_name.truncate(34)
                  else "Administración de Productos"
                  end
  end

  def product_params
    params.require(:product).permit(
      :category_id, :subcategory_id, :product_name, :sku, :price, :price_discount,
      :brand, :product_description, :colors, :weight, :height, :width, :length,
      :stock_quantity,
      product_images: [],  # Permite cargar nuevas imágenes
      bar_codes_attributes: [:id, :code, :_destroy],
    )
  end



  # def product_params
  #   params.require(:product).permit(
  #     :category_id, :subcategory_id, :product_name, :sku, :price, :price_discount,
  #     :brand, :product_description, :colors, :weight, :height, :width, :length,
  #     :stock_quantity,
  #     product_images: [],
  #     bar_codes_attributes: [:id, :code, :_destroy],
  #     product_images_attributes: [:id, :_destroy]  # Permite _destroy para eliminar imágenes
  #   )
  # end

end
