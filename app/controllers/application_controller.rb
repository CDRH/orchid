class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale

  def set_locale
    I18n.locale = params["locale"] || APP_OPTS["language_default"] || "en"
  end

  def default_url_options
    { locale: I18n.locale }
  end

  if API_PATH
    $api = ApiBridge::Query.new(API_PATH, Facets.facet_list, API_OPTS)
    logger.info("Connecting to API at #{API_PATH}")
  else
    raise "No API path found for project, please make sure the config file is correctly filled out"
  end
end
