module Orchid
  module Routing
    module_function

    def draw(reserved_names: [], parent_prefix: "", parent_scope: "")
      # Retrieve list of main app's route names
      drawn_routes = defined?(Rails.application.routes) ?
        Rails.application.routes.routes.map { |r| r.name } : []

      eval_routes = proc {
        # if app has specified multiple language support
        # then they should be included as possible routes
        # the default language should NOT be specified
        # as it will not have a locale in the URL
        langs = APP_OPTS["languages"]
        if langs.present?
          locales = Regexp.new(langs)
          scope "(:locale)", constraints: { locale: locales } do
            ROUTES.each do |route|
              next if drawn_routes.include?(route[:name])
              # Call routing DSL methods in Orchid route procs in this context
              instance_exec(parent_prefix, &route[:definition])
            end
          end
        else
          ROUTES.each do |route|
            next if drawn_routes.include?(route[:name])
            # Call routing DSL methods in Orchid route procs in this context
            instance_exec(parent_prefix, &route[:definition])
          end
        end
      }

      # If home path drawn, assume Orchid's routes have already been drawn
      if !drawn_routes.include?("home") && const_defined?(:APP_OPTS)
        Rails.application.routes.draw do
          # Add names reserved by main app for more general routes, e.g. '/:id'
          drawn_routes += reserved_names

          if parent_scope.present?
            scope parent_scope do
              instance_eval(&eval_routes)
            end
          else
            instance_eval(&eval_routes)
          end
        end
      end # end if !drawn_routes.include?("home")
    end # end draw method
  end
end
