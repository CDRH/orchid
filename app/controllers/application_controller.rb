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
  if defined? SECTIONS
    $api_sections = {}
    SECTIONS.each do |section, config|
      $api_sections[section] = ApiBridge::Query.new(API_PATH,
        Facets.section_list(section), config["api_options"])
      logger.info("Connecting to API for section: #{section}")
    end
  end

  private

  # Render section overrides and localized views
  # View name does not include the locale or extensions
  # Example:
  #   render_overridable("explore/pages", "index")
  #   Looks for in order:
  #     If @section defined & locale == "es", "@section/index_es.html.erb"
  #     If @section defined & no locale, "@section/index.html.erb"
  #     If no @section & locale == "es", "explore/pages/index_es.html.erb"
  #     If no @section or locale, "explore/pages/index.html.erb"
  #  If no view found, render an error message with missing view path
  def render_overridable(path="", view="", **kwargs)
    # If only one arg, give view the arg value and empty path
    if view == ""
      view = path
      # Set to lookup_context.prefixes so calls to template_exists? work
      path = lookup_context.prefixes
    end

    # If view still empty (no args), use controller action as view name
    if view == ""
      view = params[:action]
    end

    # False when looking for views rather than partials
    is_partial = false
    localized = "#{view}_#{locale}"

    if @section.present? && lookup_context.template_exists?(localized, @section,
                                                            is_partial)
      path = "#{@section}"
      view = localized
    elsif @section.present? && lookup_context.template_exists?(view,
                                                               @section,
                                                               is_partial)
      path = "#{@section}"
    elsif lookup_context.template_exists?(localized, path, is_partial)
      view = localized
    elsif !lookup_context.template_exists?(view, path, is_partial)
      # Log error and display 404 view if view is missing
      path << "/" if path.present?
      logger.error("render_overridable unable to find view: #{path}#{view}")

      return render "errors/not_found", status: 404
    end

    # Revert earlier assignment so render argument passed as desired
    path = "" if path == lookup_context.prefixes

    path << "/" if path.present?

    render "#{path}#{view}", kwargs
  end

  def set_section
    @section = params[:section]
    @section.chomp!("_") if @section.present?
    params.delete :section
  end
end
