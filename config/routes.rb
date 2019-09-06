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
        { name: 'home', definition: proc { |section|
          section += "_" if section.present?
          root 'general#index', as: "#{section}home"
        }},

        # General
        { name: 'about', definition: proc { |section|
          section += "_" if section.present?
          get 'about', to: 'general#about', as: "#{section}about"
        }},

        # Items
        { name: 'browse', definition: proc { |section|
          section += "_" if section.present?
          get 'browse', to: 'items#browse', as: "#{section}browse",
            defaults: { section: section }
        }},
        { name: 'browse_facet', definition: proc { |section|
          section += "_" if section.present?
          get 'browse/:facet', to: 'items#browse_facet',
            as: "#{section}browse_facet", constraints: { facet: with_period },
            defaults: { section: section }
        }},
        { name: 'item', definition: proc { |section|
          section += "_" if section.present?
          get 'item/:id', to: 'items#show', as: "#{section}item",
            constraints: { id: with_period }, defaults: { section: section }
        }},
        { name: 'search', definition: proc { |section|
          section += "_" if section.present?
          get 'search', to: 'items#index', as: "#{section}search",
            defaults: { section: section }
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
