Rails.application.routes.draw do
  root to: 'products#index'

  get '/products', to: 'products#index'
  get '/products/detail/:name', to: 'products#detail', name: /.*/
  get '/products/list/:model', to: 'products#model_list', constraints: { model: %r{[^/]+} }
  get '/products/list/favorite/:user_id', to: 'products#favorite_list'
  get '/products/list/history/:user_id', to: 'products#history_list'

  get '/api/users/:uuid', to: 'users#show'

  get '/api/favorites/user/:user_id', to: 'favorites#index'
  get '/api/favorites/:user_id/:case_name', to: 'favorites#show'
  post '/api/favorites/:user_id/:product_id', to: 'favorites#create'
  delete '/api/favorites/:user_id/:product_id', to: 'favorites#destroy'

  post '/api/histories', to: 'histories#create'
end
