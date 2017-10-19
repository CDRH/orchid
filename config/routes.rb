Orchid::Engine.routes.draw do
  # TODO put any namespaced or orchid specific routes here
end

# engine includes routes after the app includes routes
Orchid::Engine.draw_routes

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
#   > Orchid::Engine.draw_routes
#   to your routes file, then add your routes.
#
# I want to add a route after the orchid defaults which overrides a named path
#
#   You will manually load the orchid routes as above, but pass the name that
#   you will be overriding to the orchid method.
#   > Orchid::Engine.draw_routes("item")
#   You can also pass a list
#   > Orchid::Engine.draw_routes("item", "home", "browse")
#   then add overriding routes to your file as you normally would
