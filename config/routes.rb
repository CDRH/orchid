Orchid::Engine.routes.draw do
  # TODO put any namespaced or orchid specific routes here
end

Rails.application.routes.draw do
  root 'general#index', as: :home
  get 'about' => 'general#about', as: :about

  # items
  get 'browse' => 'items#browse', as: :browse
  get 'item/:id' => 'items#show', as: :item, :contrains => { :id => /[^\/]+/ }
  get 'search' => 'items#index', as: :search

  # errors
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#server_error', via: :all
end
