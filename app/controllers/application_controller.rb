class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_categories
  before_action :set_cart
  before_action :authorize_admin, if: :admin_namespace?


  def after_sign_in_path_for(resource)
    if resource.administrador?
      admin_root_path
    else
      root_path
    end
  end


  protected

  def authorize_admin
    unless current_user&.administrador?
      redirect_to root_path
    end
  end

  def admin_namespace?
    self.class.module_parent_name == "Admin"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :role, :phone, :dni])
  end

  def set_categories
    @categories = Category.all
  end

  def set_cart
    @cart = current_user&.cart || current_user&.create_cart
  end

end
