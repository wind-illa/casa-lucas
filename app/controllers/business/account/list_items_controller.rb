module Business
  module Account
    class ListItemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_list

      def create
        @list_item = @list.list_items.new(product_id: params[:product_id])
        if @list_item.save
          redirect_to business_account_list_path(@list), notice: 'Producto agregado a la lista'
        else
          redirect_back fallback_location: business_account_list_path(@list), alert: 'Ya estaba en la lista'
        end
      end

      def destroy
        @list_item = @list.list_items.find(params[:id])
        @list_item.destroy
        redirect_to business_account_list_path(@list), notice: 'Producto eliminado de la lista'
      end

      private

      def set_list
        @list = current_user.lists.find(params[:list_id])
      end
    end
  end
end
