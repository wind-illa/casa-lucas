module Business
  module Help
    class StaticPagesController < ApplicationController
      before_action :hide_navbar

      def index; end
      def about; end
      def contact; end
      def constancia_arca; end

      private

      def hide_navbar
        @hide_navbar = true
      end

    end
  end
end
