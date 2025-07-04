Rails.application.routes.draw do



  # Home Principal ---------------------------
  namespace :main, path: '' do
    root to: 'home#index'
    get 'nosotros', to: 'static_pages#about', as: :about
    get 'contacto', to: 'static_pages#contact', as: :contact
  end


  post 'mercado_pago/webhook', to: 'mercado_pago_webhooks#receive'

  # E-commerce Principal -------------------------------------------------------------------------
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

    resource :cart, only: [:show], path: 'carrito' do
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






  # modulo de administración
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

    resources :users do
      collection do
        get 'clientes', to: 'users#clientes'
        get 'admins', to: 'users#admins'
      end
      resources :addresses, only: [:create, :edit, :update, :destroy, :new]
    end

    namespace :users, path: 'usuarios' do
      get '/', to: 'main#index', as: :main
      resources :administradores, only: [:index, :show, :edit, :new, :create, :update, :destroy] do
        member do
          patch :toggle_status
        end
      end
      resources :repositores, only: [:index, :show, :edit, :new, :create, :update, :destroy]
      resources :cajeros, only: [:index, :show, :edit, :new, :create, :update, :destroy]
      resources :clientes_regular, only: [:index, :show, :edit, :new, :create, :update, :destroy]
      resources :clientes_mayorista, only: [:index, :show, :edit, :new, :create, :update, :destroy]
    end

  end

  # Módulo de minoristas
  namespace :store do
    root to: 'home#index'
  end

  # Módulo de mayoristas
  namespace :business do
    # Página principal y estáticas
    root to: 'home#index'

    # Búsqueda y vistas especiales de productos
    get 'productos/search', to: 'products#search', as: :search_products
    get 'super-ofertas', to: 'products#super_offers', as: :super_offers
    get 'novedades', to: 'products#new_arrivals', as: :new_arrivals
    get 'mas-vendidos', to: 'products#best_sellers', as: :best_sellers
    get 'historial', to: 'products#history', as: :history
    delete 'historial', to: 'products#clear_history', as: :clear_history
    delete 'historial/:id', to: 'products#remove_from_history', as: :remove_from_history

    # Navegación por categorías
    resources :categories, only: [:index, :show], path: 'categorias' do
      resources :subcategories, only: [:index, :show], path: 'subcategorias' do
        resources :products, only: [:index, :show], path: 'productos'
      end
    end

    # Productos y variantes
    resources :products, only: [:index, :show], path: 'productos' do
      resources :product_variants, only: [:show]
    end

    # Carrito
    resource :cart, only: [:show], path: 'carrito' do
      delete 'vaciar', to: 'carts#clear_cart', as: :clear_cart
    end

    resources :cart_items, only: [:create, :update, :destroy], path: 'carrito/items'

    # Órdenes
    resources :orders, only: [:new, :show, :index], path: 'compras' do
      member do
        get 'informacion-envio', to: 'orders#shipping_info', as: :shipping_info
        patch 'informacion-envio', to: 'orders#update_shipping_info', as: :update_shipping_info

        get 'envio', to: 'orders#shipping', as: :shipping
        patch 'envio', to: 'orders#update_shipping', as: :update_shipping

        get 'pago', to: 'orders#payment', as: :payment
        patch 'pago', to: 'orders#update_payment', as: :update_payment

        get 'resumen', to: 'orders#summary', as: :summary
        post 'finalizar', to: 'orders#finalize', as: :finalize
        post :cancel
        get :pdf
        get 'exito', to: 'orders#success', as: :success
        patch :upload_comprobante
      end
    end

    # Cuenta del usuario
    namespace :account, path: 'mi-cuenta' do
      get '/', to: 'main#show', as: :main

      resource :profile, only: [:show, :update], path: 'perfil' do
        get 'informacion', on: :collection
        get 'editar-nombre', to: 'profiles#edit_name', as: :edit_name
        get 'editar-telefono', to: 'profiles#edit_phone', as: :edit_phone
        get 'editar-dni', to: 'profiles#edit_dni', as: :edit_dni
        patch 'foto', to: 'profiles#update_profile_picture', as: :update_picture

        get 'verificacion-fiscal', to: 'profiles#fiscal_verification_form', as: :fiscal_verification_form
        patch 'constancia-fiscal', to: 'profiles#upload_constancia_fiscal', as: :upload_constancia_fiscal
        get 'verificacion-en-proceso', to: 'profiles#fiscal_verification_pending', as: :fiscal_verification_pending
      end

      resources :lists, only: [:index, :show, :new, :create, :destroy], path: 'listas' do
        resources :list_items, only: [:create, :destroy], path: 'productos'
      end

      resources :addresses, only: [:index, :new, :create, :edit, :update, :destroy, :show], path: 'direcciones' do
        member do
          patch :set_default
        end
      end

      resources :transporte_preferidos, only: [:index, :new, :create, :edit, :update, :destroy], path: 'transportes-preferidos' do
        member do
          patch :set_default
        end
      end


      resources :orders, only: [:index, :show], path: 'compras'
      resource :facturacion, only: [:show], path: 'facturacion'


      resource :settings, only: [:show], path: 'configuracion' do
        delete 'eliminar-cuenta', on: :collection, to: 'settings#delete_account', as: :delete_account

        get 'editar-contrasena', to: 'settings#edit_password', as: :edit_password
        patch 'actualizar-contrasena', to: 'settings#update_password', as: :update_password

        get 'editar-email', to: 'settings#edit_email', as: :edit_email
        patch 'actualizar-email', to: 'settings#update_email', as: :update_email
      end

    end

    # Centro de ayuda
    namespace :help, path: 'ayuda' do
      get '/', to: 'static_pages#index', as: :index
      get 'nosotros', to: 'static_pages#about', as: :about
      get 'contacto', to: 'static_pages#contact', as: :contact
      get 'constancia-arca', to: 'static_pages#constancia_arca', as: :constancia_arca
      # Más artículos en el futuro:
      # get 'como-comprar', to: 'static_pages#how_to_buy', as: :how_to_buy
    end



  end

  # Módulo de punto de venta (POS)
  namespace :pos do
    root to: 'home#index'
  end

  # Módulo de logística
  namespace :logistics do
    root to: 'home#index'
  end












































  # Account -----------------------------------------------------------------------------------------
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
