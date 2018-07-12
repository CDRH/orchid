module Orchid
  module Routing
    module_function

    def draw(reserved_names: [])
      # Retrieve list of main app's route names
      drawn_routes = defined?(Rails.application.routes) ?
        Rails.application.routes.routes.map { |r| r.name } : []

      # If home path drawn, assume Orchid's routes have already been drawn
      if !drawn_routes.include?("home")
        Rails.application.routes.draw do
          # Add names reserved by main app for more general routes, e.g. '/:id'
          drawn_routes += reserved_names

          langs = APP_OPTS["languages"]
          locales = langs ? Regexp.new(langs) : /en/

          scope "(:locale)", locale: locales do
            ROUTES.each do |route|
              next if drawn_routes.include?(route[:name])

              # Call routing DSL methods in Orchid route procs in this context
              instance_eval(&route[:definition])
            end
          end
        end
      end
    end
  end
end
