class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale, :set_section

  def set_locale
    I18n.locale = params["locale"] || APP_OPTS["language_default"] || "en"
  end

  def default_url_options
    params["locale"] ? { locale: I18n.locale } : {}
  end

  if API_PATH
    $api = ApiBridge::Query.new(API_PATH, Facets.facet_list, API_OPTS)
    logger.info("Connecting to API at #{API_PATH}")
  else
    raise "No API path found for project, please make sure the config file is correctly filled out"
  end

  # Section API objects
  if SECTIONS
    SECTIONS.each do |section, config|
      $api_sections = {}
      $api_sections[section] = ApiBridge::Query.new(API_PATH, Facets.facet_list,
        config["api_options"])
      logger.info("Connecting to API for section: #{section}")
    end
  end

  private

  def render_overridable(path, template, is_partial: false, **kwargs)
    if @section.present? && lookup_context.template_exists?(template, @section,
                                                            is_partial)
      path = @section
    end

    render "#{path}/#{template}", kwargs
  end

  def set_section
    @section = params[:section]
    @section.chomp!("_")
    params.delete :section
  end
end
