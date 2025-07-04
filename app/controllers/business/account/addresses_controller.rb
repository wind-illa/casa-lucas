module Business
  module Account
    class AddressesController < ApplicationController
      before_action :set_envio_address, only: [:edit, :update, :destroy]

      def index
        @envio_addresses = current_user.addresses.direccion_envio.order(created_at: :desc)
      end

      def new
        @envio_address = current_user.addresses.new(address_type: :direccion_envio)
      end

      def create
        @envio_address = current_user.addresses.new(address_params)
        @envio_address.address_type = :direccion_envio

        # Si no se marcó como default y no hay ninguna dirección predeterminada aún
        if !@envio_address.default_shipping && current_user.addresses.where(default_shipping: true).empty?
          @envio_address.default_shipping = true
        end

        if @envio_address.save
          redirect_to business_account_addresses_path, notice: 'Dirección creada correctamente.'
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def set_default
        current_user.addresses.update_all(default_shipping: false)
        address = current_user.addresses.find(params[:id])
        address.update(default_shipping: true)
        redirect_to business_account_addresses_path, notice: "Dirección principal actualizada."
      end

      def update
        if @envio_address.update(address_params)
          redirect_to business_account_addresses_path, notice: 'Dirección actualizada correctamente.'
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        was_default = @envio_address.default_shipping
        @envio_address.destroy

        if was_default
          next_default = current_user.addresses.order(created_at: :asc).first
          next_default.update(default_shipping: true) if next_default.present?
        end

        redirect_to business_account_addresses_path, notice: 'Dirección eliminada correctamente.'
      end

      private

      def set_envio_address
        @envio_address = current_user.addresses.direccion_envio.find(params[:id])
      end

      def address_params
        params.require(:address).permit(
          :street_name,
          :street_number,
          :floor,
          :apartment,
          :locality,
          :city,
          :province_code,
          :postal_code,
          :indications,
          :default_shipping
        )
      end
    end
  end
end
