Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # parameter token is a JsonWebToken and contains dots
  #   - trick found here: https://github.com/rails/rails/issues/28901
  scope format: false do
    defaults format: 'json' do
      patch '/', to: 'secure_data_storages#update'

      constraints token: %r{/^[a-zA-Z0-9\-_]+?\.[a-zA-Z0-9\-_]+?\.([a-zA-Z0-9\-_]+)?$/} do
        # get 'secure_data_storages/:token', to: 'secure_data_storages#show'
        get ':token', to: 'secure_data_storages#show'
      end

      root to: 'secure_data_storages#new'
    end
  end
end
