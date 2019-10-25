class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale, :set_section

  def set_locale
    I18n.locale = params["locale"] || APP_OPTS["language_default"] || "en"
  end

  def default_url_options
    params["locale"] ? { locale: I18n.locale } : {}
  end

  private

  # Render section overrides
  # View name does not include the locale or extensions
  # Example:
  #   render_overridable("explore/pages", "index")
  #   Looks for in order:
  #     If @section defined & no locale, "@section/index.html.erb"
  #     If no @section or locale, "explore/pages/index.html.erb"
  #  If no view found, render an error message with missing view path
  def render_overridable(path="", view="", **kwargs)
    # Only one arg will be passed if replacing a simple `render "template"` call
    # In that case, set view to arg value assigned to path and empty path
    if view == ""
      view = path
      # template_exists? still needs a path to search; lookup_context.prefixes
      # is what render code uses when only one arg, so assign it to path here
      path = lookup_context.prefixes
    end

    # If view still empty (no args), use controller action as view name
    if view == ""
      view = params[:action]
    end

    # False when looking for views rather than partials
    is_partial = false

    if @section.present? && lookup_context.template_exists?(view,
      "#{@section}/#{path}", is_partial)
      path = "#{@section}/#{path}"
    elsif !lookup_context.template_exists?(view, path, is_partial)
      # Log error and display 404 view if view is missing
      path << "/" if path.present?
      logger.error("render_overridable unable to find view: #{path}#{view}")

      return render "errors/not_found", status: 404
    end

    # Revert earlier assignment of lookup_context.prefixes so render args are
    # same as simple call `render "template"` being overridden
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
