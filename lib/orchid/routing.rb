module Orchid
  module Routing
    module_function

    def draw(prefix: "", routes: [], scope: "")
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
              # Don't draw routes if not in "routes" allow list or already drawn
              next if (routes.present? && !routes.include?(route[:name])) \
                || drawn_routes.include?(route[:name])
              # Call routing DSL methods in Orchid route procs in this context
              instance_exec(prefix, &route[:definition])
            end
          end
        else
          ROUTES.each do |route|
            # Don't draw routes if not in "routes" allow list or already drawn
            next if (routes.present? && !routes.include?(route[:name])) \
              || drawn_routes.include?(route[:name])
            # Call routing DSL methods in Orchid route procs in this context
            instance_exec(prefix, &route[:definition])
          end
        end
      }

      # If home path drawn, assume Orchid's routes have already been drawn
      if !drawn_routes.include?("home") && const_defined?(:APP_OPTS)
        Rails.application.routes.draw do
          if scope.present?
            scope scope do
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
