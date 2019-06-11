require "orchid/redirect"

Rails.application.config.middleware.insert(0, Orchid::Redirect)
