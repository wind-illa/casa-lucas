Rails.application.routes.draw do



  # Home Principal ---------------------------
  namespace :main, path: '' do
    root to: 'home#index'
    get 'nosotros', to: 'static_pages#about', as: :about
    get 'contacto', to: 'static_pages#contact', as: :contact
  end


  post 'mercado_pago/webhook', to: 'mercado_pago_webhooks#receive'

  # E-commerce Principal ---------------------
  namespace :ecommerce, path: '' do

    # Ruta para búsqueda de productos
    get 'productos/search', to: 'products#search', as: :search_products


    # Vistas especiales
    get 'super-ofertas', to: 'products#super_offers', as: :super_offers
    get 'novedades',      to: 'products#new_arrivals', as: :new_arrivals
    get 'mas-vendidos',   to: 'products#best_sellers', as: :best_sellers
    get 'historial',      to: 'products#history', as: :history
    delete 'historial',   to: 'products#clear_history', as: :clear_history
    delete 'historial/:id', to: 'products#remove_from_history', as: :remove_from_history


    resources :categories, only: [:index, :show], path: 'categorias' do
      resources :subcategories, only: [:index, :show], path: 'subcategorias' do
        resources :products, only: [:index, :show], path: 'productos'
      end
    end

    resources :products, only: [:index, :show], path: 'productos' do
      resources :product_variants, only: [:show]
    end

    resource :cart, only: [:show, :index], path: 'carrito' do
      delete 'vaciar', to: 'carts#clear_cart', as: :clear_cart
    end

    resources :cart_items, only: [:create, :update, :destroy], path: 'carrito/items'

    resources :orders, only: [:new, :show, :index], path: 'compras' do
      member do
        # Nuevo paso: Selección o creación de dirección de envío
        get   'informacion-envio',  to: 'orders#shipping_info',       as: :shipping_info
        patch 'informacion-envio',  to: 'orders#update_shipping_info',  as: :update_shipping_info

        # Selección del método de envío
        get   'envio',  to: 'orders#shipping',        as: :shipping
        patch 'envio',  to: 'orders#update_shipping', as: :update_shipping

        # Selección del método de pago
        get   'pago',  to: 'orders#payment',         as: :payment
        patch 'pago',  to: 'orders#update_payment',  as: :update_payment

        # Resumen de la compra
        get 'resumen', to: 'orders#summary',         as: :summary

        # Finalización de la compra
        post 'finalizar', to: 'orders#finalize',     as: :finalize

        # Cancelar la compra
        post :cancel

        # Generar PDF de la orden
        get :pdf

        # Confirmación exitosa de la compra
        get 'exito', to: 'orders#success', as: :success

        # Subir comprobante de pago
        patch :upload_comprobante
      end

    end

  end



  # Administración ---------------------------
  namespace :admin do
    root to: 'dashboard#index'
    resources :banners
    resources :discount_ranges, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :shipping_methods, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :payment_methods, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :bank_accounts, only: [:index, :new, :create, :edit, :update, :destroy]
    resource :settings, only: [:show, :update]
    resources :mercado_pago_tokens, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :products do
      get 'load_subcategories', on: :collection
      resources :product_variants, only: [:new, :create, :edit, :update, :destroy]
    end

    resources :categories do
      resources :subcategories, only: [:index, :new, :create, :edit, :update, :destroy]
    end

    resources :users do
      collection do
        get 'clientes', to: 'users#clientes'
        get 'admins', to: 'users#admins'
      end
      resources :addresses, only: [:create, :edit, :update, :destroy, :new]
    end

    resources :orders, only: [:index, :show, :destroy, :update] do
      collection do
        get 'home', to: 'orders#home'
        get 'pendientes', to: 'orders#pendientes'
        get 'pagos', to: 'orders#pagos'
        get 'preparacion', to: 'orders#preparacion'
        get 'finalizadas', to: 'orders#finalizadas'
      end
      member do
        patch 'cambiar_estado', to: 'orders#cambiar_estado'
        get 'print', to: 'orders#print'  # Nueva ruta para impresión
      end
    end
  end




  # Account -----------------------------------
  namespace :account do
    get 'main', to: 'accounts#main', as: 'main'
    resources :profiles, only: [:show, :update] do
      collection do
        get 'information'
        get 'edit_name/:id', to: 'profiles#edit_name', as: 'edit_name'
        get 'edit_email/:id', to: 'profiles#edit_email', as: 'edit_email'
        get 'edit_phone/:id', to: 'profiles#edit_phone', as: 'edit_phone'
        get 'edit_dni/:id', to: 'profiles#edit_dni', as: 'edit_dni'
      end
      member do
        patch 'profile_picture', to: 'profiles#update_profile_picture'
      end
    end

    resources :addresses, only: [:index, :new, :create, :edit, :update, :destroy, :show]

    get 'settings', to: 'settings#show', as: :settings
    delete 'settings/delete_account', to: 'settings#delete_account', as: :delete_account_settings
  end




  # Usuario (Devise) -------------------------
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations',
    unlocks: 'users/unlocks',
  }




  # Ruta raíz de la aplicación ----------------
  get "up" => "rails/health#show", as: :rails_health_check
  root to: 'main/home#index'



end
