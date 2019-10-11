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

      draw_reusable_routes = proc {
        REUSABLE_ROUTES.each do |route|
          # Don't draw routes if not in "routes" allow list or already drawn
          next if (routes.present? && !routes.include?(route[:name])) \
            || drawn_routes.include?(route[:name])

          instance_eval(&route[:definition])
        end
      }

      i18n_scope = proc {
        ROUTES.each do |route|
          # Don't draw routes if already drawn
          next if drawn_routes.include?(route[:name])

          instance_eval(&route[:definition])
        end

        # Reusable routes may be scoped by section name or custom scope path
        scope_path = section.present? && scope.blank? ? "/#{section}" : scope
        if scope_path.present?
          scope scope_path, as: section, defaults: { section: section } do
            instance_eval(&draw_reusable_routes)
          end
        else
          instance_eval(&draw_reusable_routes)
        end
      }

      Rails.application.routes.draw do
        # If multiple languages, scope routes for i18n locales
        if locales.present?
          scope "(:locale)", constraints: { locale: locales } do
            instance_eval(&i18n_scope)
          end
        else
          instance_eval(&i18n_scope)
        end
      end # Rails application route drawing block
    end # draw method
  end
end
