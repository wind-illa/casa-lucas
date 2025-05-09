class Admin::SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_navbar_title

  def show
  end

  private


  def set_navbar_title
    @navbar_title = case action_name
                    when 'show' then "Configuración"
                    else "Inicio"
                    end
  end

end
