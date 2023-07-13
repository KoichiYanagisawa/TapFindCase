Rails.application.routes.draw do
  root to: 'products#index'
  get '/products', to: 'products#index'
  get '/products/models/:model', to: 'products#show', as: 'product_model'
  get '/products/detail/:id', to: 'products#detail', as: 'product_detail'
end
