module Business
  module Account
    class ListsController < ApplicationController
      before_action :authenticate_user!

      def index
        @lists = current_user.lists
      end

      def show
        @list = current_user.lists.find(params[:id])
        @products = @list.products
      end

      def new
        @list = current_user.lists.new
      end

      def create
        @list = current_user.lists.new(list_params)
        if @list.save
          redirect_to business_account_lists_path, notice: "Lista creada"
        else
          render :new
        end
      end

      private

      def list_params
        params.require(:list).permit(:name)
      end
    end
  end
end
