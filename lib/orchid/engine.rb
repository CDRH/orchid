module Orchid
  class Engine < ::Rails::Engine
    isolate_namespace Orchid

    initializer "orchid.assets.precompile" do |app|
      app.config.assets.precompile += %w(
        application.js
        application.scss
      )
    end
  end
end
