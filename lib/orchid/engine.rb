module Orchid
  class Engine < ::Rails::Engine
    isolate_namespace Orchid

    @@routes_drawn = false

    def self.draw_routes(*reserved_names)
      # skip if this method has already been manually called from application
      if !routes_drawn?
        Rails.application.routes.draw do

          # generate a list of all the route names from the app running orchid
          # and add any names that the app will be using after drawing the defaults
          app_route_names = Rails.application.routes.routes.map { |r| r.name }
          app_route_names += reserved_names

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

          @@routes_drawn = true
        end
      else
        puts "the routes have already been drawn!!!"
      end
    end

    def self.routes_drawn?
      @@routes_drawn
    end
  end
end
