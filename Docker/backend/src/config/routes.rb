Rails.application.routes.draw do

  root to: 'products#index'

  get '/products', to: 'products#index'
  get '/products/detail/:id', to: 'products#detail'
  get '/products/list/:model', to: 'products#modelList'
  get '/products/list/favorite/:user_id', to: 'products#favoriteList'

  get '/api/users/:uuid', to: 'users#show'

  get '/api/favorites/user/:user_id', to: 'favorites#index'
  get '/api/favorites/:user_id/:product_id', to: 'favorites#show'
  post '/api/favorites/:user_id/:product_id', to: 'favorites#create'
  delete '/api/favorites/:user_id/:product_id', to: 'favorites#destroy'
end
