# Load routes into Orchid::Routing::ROUTES constant before main app's routing
require_relative "../../config/routes"

module Orchid
  class Routing

    # Indicate draw method below available in routes.rb when run by Rails
    @@ready_to_draw = true

    # Only draw Orchid routes once: before, between, or after main app's routes
    @@routes_drawn = false

    def self.draw(reserved_names: [])
      if !@@routes_drawn
        Rails.application.routes.draw do
          # Retrieve list of main app's route names
          app_route_names = Rails.application.routes.routes.map { |r| r.name }

          # Add names reserved by main app for more general routes, e.g. '/:id'
          app_route_names += reserved_names

          # Handle apps with relative url root
          url_prefix = Rails.application.config.relative_url_root.present? ?
            Rails.application.config.relative_url_root : "/"

          scope url_prefix do
            ROUTES.each do |route|
              next if app_route_names.include?(route[:name])

              # Call routing DSL methods in Orchid route procs in this context
              instance_eval(&route[:definition])
            end
          end

          @@routes_drawn = true
        end
      end
    end

  end
end
