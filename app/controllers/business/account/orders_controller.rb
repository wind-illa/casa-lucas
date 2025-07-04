module Business
  module Account
    class OrdersController < ApplicationController
      before_action :authenticate_user!

      def index
        @orders = current_user.orders.order(created_at: :desc).page(params[:page]).per(10)
      end

      def show
        @order = current_user.orders.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to business_account_orders_path, alert: 'Compra no encontrada.'
      end
    end
  end
end
