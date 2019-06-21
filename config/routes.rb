# Symlinked from initializers/routes.rb so ROUTES defined for main app's routing
# in case Orchid routes to be drawn before or between main app's
# Run a second time automatically by Rails after main app's routing

# For more information, please refer to the README's Configuration section

module Orchid
  module Routing
    if !defined? ROUTES
      with_period = /[^\/]+/

      ROUTES = [
        # Home
        { name: 'home', definition: proc { |prefix|
          prefix += "_" if prefix.present?
          root 'general#index', as: "#{prefix}home"
        }},

        # General
        { name: 'about', definition: proc { |prefix|
          prefix += "_" if prefix.present?
          get 'about', to: 'general#about', as: "#{prefix}about"
        }},

        # Items
        { name: 'browse', definition: proc { |prefix|
          prefix += "_" if prefix.present?
          get 'browse', to: 'items#browse', as: "#{prefix}browse",
            defaults: { section: prefix }
        }},
        { name: 'browse_facet', definition: proc { |prefix|
          prefix += "_" if prefix.present?
          get 'browse/:facet', to: 'items#browse_facet',
            as: "#{prefix}browse_facet", constraints: { facet: with_period },
            defaults: { section: prefix }
        }},
        { name: 'item', definition: proc { |prefix|
          prefix += "_" if prefix.present?
          get 'item/:id', to: 'items#show', as: "#{prefix}item",
            constraints: { id: with_period }, defaults: { section: prefix }
        }},
        { name: 'search', definition: proc { |prefix|
          prefix += "_" if prefix.present?
          get 'search', to: 'items#index', as: "#{prefix}search",
            defaults: { section: prefix }
        }},

        # Errors
        { name: 'not_found', definition: proc {
          match '/404', to: 'errors#not_found', via: :all
        }},
        { name: 'server_error', definition: proc {
          match '/500', to: 'errors#server_error', via: :all
        }}
      ]
    else
      # Draw routes second time this code is called for routing after main app's
      draw
    end
  end
end
