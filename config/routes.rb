# Run by lib/orchid/routing.rb so ROUTES defined when doing main app's routing
# in case Orchid routes to be drawn before or between main app's
# Run a second time automatically by Rails after main app's routing
module Orchid
  class Routing
    if !defined? ROUTES
      with_period = /[^\/]+/

      ROUTES = [
        # General
        { name: 'about', definition: proc {
          get 'about', to: 'general#about', as: :about
        }},

        # Items
        { name: 'browse', definition: proc {
          get 'browse', to: 'items#browse', as: :browse
        }},
        { name: 'browse_facet', definition: proc {
          get 'browse/:facet', to: 'items#browse_facet', as: :browse_facet,
            constraints: { facet: with_period }
        }},
        { name: 'item', definition: proc {
          get 'item/:id', to: 'items#show', as: :item,
            constraints: { id: with_period }
        }},
        { name: 'search', definition: proc {
          get 'search', to: 'items#index', as: :search
        }},

        # Errors
        { name: 'not_found', definition: proc {
          match '/404', to: 'errors#not_found', via: :all
        }},
        { name: 'server_error', definition: proc {
          match '/500', to: 'errors#server_error', via: :all
        }}
      ]
    end

    # Draw routes second time this code is called for routing after main app's
    draw if defined? @@ready_to_draw
  end
end

# TODO Move documentation on how to use to README
# OVERRIDING ROUTES
#
# I want to change one of the named routes from orchid to a new path
#
#   Assuming that your overridden route can be loaded before the orchid
#   routes (for example, at a path that won't accidentally catch
#   other routes if it is loaded first (/:id) )
#   Simply add your route to the app routes file as normal
#
# I want to add a route after the orchid defaults have been drawn
#
#   You will need to manually load the orchid routes.  Do this by adding
#   > Orchid::Routing.draw
#   to your routes file, then add your routes.
#
# I want to add a route after the orchid defaults which overrides a named path
#
#   You will manually load the orchid routes as above, but pass the name that
#   you will be overriding to the orchid method.
#   > Orchid::Routing.draw(reserved_names: ["item"])
#   You can also pass a list
#   > Orchid::Routing.draw(reserved_names: ["item", "home", "browse"])
#   then add overriding routes to your file as you normally would
