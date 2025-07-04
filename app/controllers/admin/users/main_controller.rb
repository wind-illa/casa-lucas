module Admin
  module Users
    class MainController < ApplicationController
      before_action :authenticate_user!
      def index
        @users = User.order(created_at: :desc).limit(10)
        @total_users = User.count

        @role_counts = User.group(:role).count

        @role_labels = {
          "administrador" => "Administradores",
          "repositor" => "Repositores",
          "cajero" => "Cajeros",
          "cliente_regular" => "Clientes Regular",
          "cliente_mayorista" => "Clientes Mayorista"
        }

        @role_names = @role_labels.values
        @role_values = @role_labels.keys.map { |k| @role_counts[k] || 0 }
      end
    end
  end
end
