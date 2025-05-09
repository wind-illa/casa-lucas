class Admin::BannersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_navbar_title

  def index
    @banners = Banner.all
  end

  def new
    @banner = Banner.new
  end

  # def create
  #   @banner = Banner.new(banner_params)
  #   if @banner.save
  #     process_images_and_links(@banner, params[:banner][:desktop_links], params[:banner][:mobile_links])
  #     redirect_to admin_banners_path, notice: 'Banner creado con éxito.'
  #   else
  #     flash.now[:alert] = "Por favor, completa todos los campos obligatorios."
  #     render :new
  #   end
  # end

  def create
    @banner = Banner.new(banner_params.except(:desktop_images, :mobile_images))

    # Procesamos imágenes de desktop si existen
    if params[:banner][:desktop_images].present?
      desktop_files = []

      params[:banner][:desktop_images].reject(&:blank?).each_with_index do |image, index|
        processed_image = ImageProcessing::MiniMagick
          .source(image)
          .resize_to_limit(1400, 500)
          .convert("webp")
          .call

        desktop_files << {
          io: processed_image,
          filename: "desktop_banner_#{index + 1}.webp",
          content_type: "image/webp"
        }
      end
      desktop_files.each { |file| @banner.desktop_images.attach(file) }
    end

    # Procesamos imágenes de mobile si existen
    if params[:banner][:mobile_images].present?
      mobile_files = []

      params[:banner][:mobile_images].reject(&:blank?).each_with_index do |image, index|
        processed_image = ImageProcessing::MiniMagick
          .source(image)
          .resize_to_limit(750, 320)
          .convert("webp")
          .call

        mobile_files << {
          io: processed_image,
          filename: "mobile_banner_#{index + 1}.webp",
          content_type: "image/webp"
        }
      end
      mobile_files.each { |file| @banner.mobile_images.attach(file) }
    end

    if @banner.save
      redirect_to admin_banners_path, notice: 'Banner creado con éxito.'
    else
      flash.now[:alert] = "Por favor, completa todos los campos obligatorios."
      render :new, status: :unprocessable_entity
    end
  end



  def edit
    @banner = Banner.find(params[:id])
  end

  # def update
  #   @banner = Banner.find(params[:id])

  #   # Actualizar el banner con los parámetros permitidos (sin las imágenes)
  #   if @banner.update(banner_params.except(:desktop_images, :mobile_images))

  #     # Procesar enlaces de imágenes de escritorio
  #     if params[:banner][:desktop_links].present?
  #       @banner.update(desktop_links: params[:banner][:desktop_links])
  #     end

  #     # Procesar enlaces de imágenes móviles
  #     if params[:banner][:mobile_links].present?
  #       @banner.update(mobile_links: params[:banner][:mobile_links])
  #     end

  #     # Verificar y reemplazar la imagen de escritorio
  #     if params[:banner][:desktop_images].present?
  #       @banner.desktop_images.purge # Eliminar la imagen existente
  #       # Adjuntar la nueva imagen
  #       @banner.desktop_images.attach(params[:banner][:desktop_images])
  #     end

  #     # Verificar y reemplazar la imagen móvil
  #     if params[:banner][:mobile_images].present?
  #       @banner.mobile_images.purge # Eliminar la imagen existente
  #       # Adjuntar la nueva imagen
  #       @banner.mobile_images.attach(params[:banner][:mobile_images])
  #     end


  #     redirect_to admin_banners_path, notice: 'Banner actualizado exitosamente.'
  #   else
  #     flash.now[:alert] = "Por favor, completa todos los campos obligatorios."
  #     render :edit
  #   end
  # end

  def update
    @banner = Banner.find(params[:id])

    if @banner.update(banner_params.except(:desktop_images, :mobile_images))

      # Reemplazar imágenes de escritorio si se envían nuevas
      if params[:banner][:desktop_images].present?
        @banner.desktop_images.purge
        desktop_files = []

        Array(params[:banner][:desktop_images]).reject(&:blank?).each_with_index do |image, index|
          processed_image = ImageProcessing::MiniMagick
            .source(image)
            .resize_to_limit(1800, 500)
            .convert("webp")
            .call

          desktop_files << {
            io: processed_image,
            filename: "desktop_banner_#{index + 1}.webp",
            content_type: "image/webp"
          }
        end

        desktop_files.each { |file| @banner.desktop_images.attach(file) }
      end

      # Reemplazar imágenes móviles si se envían nuevas
      if params[:banner][:mobile_images].present?
        @banner.mobile_images.purge
        mobile_files = []

        Array(params[:banner][:mobile_images]).reject(&:blank?).each_with_index do |image, index|
          processed_image = ImageProcessing::MiniMagick
            .source(image)
            .resize_to_limit(1200, 600)
            .convert("webp")
            .call

          mobile_files << {
            io: processed_image,
            filename: "mobile_banner_#{index + 1}.webp",
            content_type: "image/webp"
          }
        end

        mobile_files.each { |file| @banner.mobile_images.attach(file) }
      end

      redirect_to admin_banners_path, notice: 'Banner actualizado exitosamente.'
    else
      flash.now[:alert] = "Por favor, completa todos los campos obligatorios."
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    redirect_to admin_banners_path
  end

  private

  def set_navbar_title
    case action_name
    when 'index'
      @navbar_title = "Banners"
    when 'new'
      @navbar_title = "Nuevo"
    when 'edit'
      @navbar_title = "Editar"
    else
      @navbar_title = "Administración"
    end
  end


  def banner_params
    params.require(:banner).permit(:title, :desktop_links, :mobile_links,
                                   desktop_images: [], mobile_images: [])
  end



  def process_images_and_links(banner, desktop_links, mobile_links)
    # Procesar enlaces de imágenes de escritorio
    if banner.desktop_images.attached? && desktop_links.present?
      links = desktop_links.split(',').map(&:strip)
      banner.desktop_images.each_with_index do |image, index|
        image.metadata[:link] = links[index] if links[index].present?
      end
    end

    # Procesar enlaces de imágenes móviles
    if banner.mobile_images.attached? && mobile_links.present?
      links = mobile_links.split(',').map(&:strip)
      banner.mobile_images.each_with_index do |image, index|
        image.metadata[:link] = links[index] if links[index].present?
      end
    end
  end
end
