# Symlinked from initializers/routes.rb so ROUTES defined for main app's routing
# in case Orchid routes to be drawn before or between main app's
# Run a second time automatically by Rails after main app's routing

# For more information, please refer to the README's Configuration section

module Orchid
  module Routing
    if !defined?(ROUTES)
      with_period = /[^\/]+/

      # Routes only drawn once
      ROUTES = [
        # Errors
        { name: 'not_found', definition: proc {
          match '/404', to: 'errors#not_found', via: :all, as: "not_found"
        }},
        { name: 'server_error', definition: proc {
          match '/500', to: 'errors#server_error', via: :all, as: "server_error"
        }}
      ]

      REUSABLE_ROUTES = [
        # Home
        { name: 'home', definition: proc {
          root 'general#index', as: "home"
        }},

        # General
        { name: 'about', definition: proc {
          get 'about', to: 'general#about', as: "about"
        }},

        # Items
        { name: 'browse', definition: proc {
          get 'browse', to: 'items#browse', as: "browse"
        }},
        { name: 'browse_facet', definition: proc {
          get 'browse/:facet', to: 'items#browse_facet', as: "browse_facet",
            constraints: { facet: with_period }
        }},
        { name: 'item', definition: proc {
          get 'item/:id', to: 'items#show', as: "item",
            constraints: { id: with_period }
        }},
        { name: 'search', definition: proc {
          get 'search', to: 'items#index', as: "search"
        }}
      ]
    else
      # Draw routes second time this code is called for routing after main app's
      draw
    end
  end
end
