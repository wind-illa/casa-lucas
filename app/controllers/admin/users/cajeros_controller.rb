module Admin
  module Users
    class CajerosController < ApplicationController
      before_action :authenticate_user!
      def index; end
      def new; end
      def create; end
      def show; end
      def edit; end
      def destroy; end
    end
  end
end
