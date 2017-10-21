module Orchid
  class Engine < ::Rails::Engine
    isolate_namespace Orchid

    config.to_prepare do
      # Load main app's controller overrides
      Dir.glob(Rails.root + "app/controllers/**/*_override.rb").each do |c|
        # Files begin with `(ControllerName)Controller.class_eval do`
        # and define or re-define methods of matching Orchid file
        require_dependency(c)
      end

      # Load main app's model overrides
      Dir.glob(Rails.root + "app/models/**/*_override.rb").each do |c|
        # Files begin with `(ModelName).class_eval do`
        # and define or re-define methods of matching Orchid file
        require_dependency(c)
      end
    end
  end
end
