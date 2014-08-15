 Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: redirect("/#{I18n.default_locale}", status: 302), as: :redirected_root
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root to: redirect("/%{locale}/quotes/new", status: 302)
    scope "/quotes/q-(:token)/" do
      get 'results', to: 'quotes#results'
    end
    resources :quotes
    resources :toweds
    scope "/apps/:token/" do
      get 'personal', to: 'apps#personal', as: 'app_personal'
      get 'vehicle', to: 'apps#vehicle', as: 'app_vehicle'
    end
    resources :apps
  end

  scope "/api/" do
    get '/vehicles/', to: 'vehicles#proxy'
    get '/vehicles/:type', to: 'vehicles#proxy'
    get '/vehicles/:type/:vehicle_type', 
      to: 'vehicles#proxy'
    get '/vehicles/:type/:vehicle_type/:make', 
      to: 'vehicles#proxy'
    get '/vehicles/:type/:vehicle_type/:make/:model', 
      to: 'vehicles#proxy'
  end
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
