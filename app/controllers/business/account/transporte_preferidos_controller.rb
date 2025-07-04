module Business
  module Account
    class TransportePreferidosController < ApplicationController
      before_action :set_transport, only: [:edit, :update, :destroy, :set_default]

      def index
        @transports = current_user.transporte_preferidos.order(created_at: :desc)
      end

      def new
        @transport = current_user.transporte_preferidos.new
      end

      def create
        @transport = current_user.transporte_preferidos.new(transport_params)

        # Si no se marcó como predeterminado y no hay ninguno aún
        if !@transport.predeterminado && current_user.transporte_preferidos.where(predeterminado: true).empty?
          @transport.predeterminado = true
        end

        if @transport.save
          redirect_to business_account_transporte_preferidos_path, notice: 'Transporte guardado correctamente.'
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @transport.update(transport_params)
          redirect_to business_account_transporte_preferidos_path, notice: 'Transporte actualizado correctamente.'
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        was_default = @transport.predeterminado
        @transport.destroy

        # Si se eliminó el transporte predeterminado, asignar otro si existe
        if was_default
          next_default = current_user.transporte_preferidos.order(created_at: :asc).first
          next_default.update(predeterminado: true) if next_default.present?
        end

        redirect_to business_account_transporte_preferidos_path, notice: 'Transporte eliminado correctamente.'
      end

      def set_default
        current_user.transporte_preferidos.update_all(predeterminado: false)
        @transport.update(predeterminado: true)

        redirect_to business_account_transporte_preferidos_path, notice: 'Transporte predeterminado actualizado.'
      end

      private

      def set_transport
        @transport = current_user.transporte_preferidos.find(params[:id])
      end

      def transport_params
        params.require(:transporte_preferido).permit(:nombre, :observaciones, :predeterminado)
      end
    end
  end
end
