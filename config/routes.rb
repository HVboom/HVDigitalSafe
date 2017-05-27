Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # parameter token is a JsonWebToken and contains dots
  #   - trick found here: https://github.com/rails/rails/issues/28901
  scope format: false do
    defaults format: 'json' do
      #get 'secure_data_storages/new'
      get 'new', to: 'secure_data_storages#new'
      root to: 'secure_data_storages#new'

      constraints token: %r{[^\/]+} do
        # get 'secure_data_storages/:token', to: 'secure_data_storages#show'
        # patch 'secure_data_storages/:token', to: 'secure_data_storages#update'
        get ':token', to: 'secure_data_storages#show'
        patch ':token', to: 'secure_data_storages#update'
      end
    end
  end
end
