module Orchid
  module Routing
    module_function

    def draw(section: "", routes: [], scope: "")
      # Retrieve list of main app's route names
      drawn_routes = defined?(Rails.application.routes) ?
        Rails.application.routes.routes.map { |r| r.name } : []

      # If multiple languages, constrain locale to non-default language codes
      locales = nil
      if defined?(APP_OPTS) && APP_OPTS["languages"].present?
        other_languages = APP_OPTS["languages"].split("|")
          .reject { |l| l == APP_OPTS["language_default"] }

        if other_languages.present?
          locales = Regexp.new(other_languages.join("|"))
        end
      end

      scope_and_draw_route = proc { |route|
        # Scope route if needed and call its routing DSL proc
        if route["scope"].present?
          scope route["scope"], as: section, defaults: { section: section } do
            instance_eval(&route[:definition])
          end
        else
          instance_eval(&route[:definition])
        end
      }

      scope_i18n = proc { |route|
        # If multiple languages, scope routes for i18n locales
        if locales.present?
          scope "(:locale)", constraints: { locale: locales } do
            instance_exec(route, &scope_and_draw_route)
          end
        else
          instance_exec(route, &scope_and_draw_route)
        end
      }

      Rails.application.routes.draw do
        REUSABLE_ROUTES.each do |route|
          # Don't draw routes if not in "routes" allow list or already drawn
          next if (routes.present? && !routes.include?(route[:name])) \
            || drawn_routes.include?(route[:name])

          # Set route scope to section name (if no scope kwarg) or scope kwarg
          route["scope"] = section.present? && scope.blank? ?
            "/#{section}" : scope

          route["reusable"] = true
          instance_exec(route, &scope_i18n)
        end

        ROUTES.each do |route|
          # Don't draw routes if already drawn
          next if drawn_routes.include?(route[:name])

          # Do not scope non-reusable routes beyond i18n scoping
          route["scope"] = ""

          instance_exec(route, &scope_i18n)
        end # non-reusable route handling
      end # Rails application route drawing block
    end # draw method
  end
end
