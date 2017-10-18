Orchid::Engine.routes.draw do
  # TODO put any namespaced or orchid specific routes here
end

Rails.application.routes.draw do

  # generate a list of all the route names from the app running orchid
  app_route_names = Rails.application.routes.routes.map { |r| r.name }

  # define orchid default routes
  default_routes = [
    { get: 'about', location: 'general#about', as: :about, constraints: {} },
    # items
    { get: 'browse', location: 'items#browse', as: :browse, constraints: {} },
    { get: 'browse/:facet', location: 'items#browse_facet', as: :browse_facet, constraints: { :facet => /[^\/]+/ } },
    { get: 'item/:id', location: 'items#show', as: :item, constraints: { :id => /[^\/]+/ } },
    { get: 'search', location: 'items#index', as: :search, constraints: {} }
  ]

  # if no route naming conflict between app and orchid, add orchid default route
  default_routes.each do |route|
    next if app_route_names.include?(route[:as].to_s)
    get route[:get] => route[:location], as: route[:as], constraints: route[:constraints]
  end

  # use default if no home path specified
  if !app_route_names.include?("home")
    root 'general#index', as: "home"
  end

  # error handling
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#server_error', via: :all

end
