module Business
  module Account
    class FacturacionsController < ApplicationController
      before_action :authenticate_user!

      def show
        @user = current_user
        @fiscal_address = @user.addresses.direccion_fiscal.first
      end
    end
  end
end
