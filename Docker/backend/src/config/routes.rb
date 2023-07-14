Rails.application.routes.draw do
  root to: 'products#index'
  get '/products', to: 'products#index'
  get '/products/models/:model', to: 'products#show', as: 'product_model'
  get '/products/detail/:id', to: 'products#detail', as: 'product_detail'
  get '/api/users/:uuid', to: 'users#show', as: 'user'
  get '/api/favorites/:user_id/:product_id', to: 'favorites#show'
  post '/api/favorites/:user_id/:product_id', to: 'favorites#create', as: 'favorite'
  delete '/api/favorites/:user_id/:product_id', to: 'favorites#destroy', as: 'delete_favorite'
end
