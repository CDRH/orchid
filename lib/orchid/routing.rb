module Orchid
  module Routing
    module_function

    def draw(section: "", routes: [], scope: "")
      # Retrieve list of main app's route names
      drawn_routes = defined?(Rails.application.routes) ?
        Rails.application.routes.routes.map { |r| r.name } : []

      # If multiple languages, constrain locale to non-default language codes
      locales = defined?(APP_OPTS) && APP_OPTS["languages"].present? ?
                  Regexp.new(APP_OPTS["languages"]) : nil

      draw_section_routes = proc { |route|
        # Set scope to section name if no scope set
        scope = "/#{section}" if section.present? && scope.blank?
        scope_path = scope

        if scope_path.present?
          scope scope_path, as: section, defaults: { section: section } do
            instance_eval(&route[:definition])
          end
        else
          instance_eval(&route[:definition])
        end
      }

      draw_i18n_routes = proc { |route|
        if locales.present?
          # If multiple languages, scope routes for i18n locales
          scope "(:locale)", constraints: { locale: locales } do
            # Call routing DSL methods of Orchid route procs in this context
            instance_exec(route, &draw_section_routes)
          end
        else
          # Call routing DSL methods of Orchid route procs in this context
          instance_exec(route, &draw_section_routes)
        end
      }

      Rails.application.routes.draw do
        REUSABLE_ROUTES.each do |route|
          # Don't draw routes if not in "routes" allow list or already drawn
          next if (routes.present? && !routes.include?(route[:name])) \
            || drawn_routes.include?(route[:name])

          instance_exec(route, &draw_i18n_routes)
        end

        ROUTES.each do |route|
          # Don't draw routes if already drawn
          next if drawn_routes.include?(route[:name])

          instance_exec(route, &draw_i18n_routes)
        end # non-reusable route handling
      end # Rails application route drawing block
    end # draw method
  end
end
