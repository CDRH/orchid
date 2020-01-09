module Orchid::ApplicationHelper

  ##
  # Return "active" string to class list if path, param, or variable matches
  #
  # == Examples
  #
  # Request for an explicit path
  # <li class="<%= active?('/about') %>">
  #
  # Request for a named path
  # <li class="<%= active?(home_path) %>">
  #
  # Request for any sub-URI request:
  # Note default current_page? comparison does not handle Regexp
  # <li class="<%= active?(/^#{config.relative_url_root}\/browse/,
  #   request.path) %>">
  #
  # Value matches the request's controller name
  # Note :controller and :action are added to params hash by Rails
  # <li class="<%= active?("search", :controller) %>">
  #
  # Any element of a list matches a parameter
  # names.each do |name|
  #   <li class="<%= active?(["foo", "bar", "baz"], :sort) %>">
  #
  # Value matches another variable
  # <li class="<%= active?(article, @current_article) %>">
  def active?(value, comparison=nil)
    if value.class == Regexp
      if comparison.nil?
        # Inform if tried to pass only a Regexp to active?
        raise "current_page? does not support Regexp comparisons"
      elsif comparison.class == Symbol
        value.match(params[comparison]) ? "active" : ""
      else
        value.match(comparison) ? "active" : ""
      end
    else
      Array(value).each do |v|
        begin
          if comparison.nil?
            return "active" if current_page? v
          elsif comparison.class == Symbol
            return "active" if current_page? comparison => v
          else
            return "active" if v == comparison
          end
        rescue
          # Rescue when current_page? throws "No route matches" exception
          return "active" if !comparison.nil? && v == params[comparison]
        end
      end

      ""
    end
  end

  def add_assets(asset_array, *assets)
    assets.each do |asset|
      if asset.is_a?(Array)
        asset_array = Array(asset_array) + asset
      else
        asset_array = Array(asset_array) << asset
      end
    end

    asset_array
  end

  def copy_params
    orchid_params = params.to_unsafe_h
    Orchid::RAILS_INTERNAL_PARAMS.each { |p| orchid_params.delete(p) }

    orchid_params
  end

  def clear_search_text
    new_params = copy_params
    new_params.delete("q")

    # Prevent relevancy sort remaining if one clicks "Clear Search Text" link
    if params["sort"].present? && params["sort"].first == "relevancy|desc"
      new_params.delete("sort")
    end

    new_params
  end

  # image is path relative to iiif server + project of image
  #   "documents/doc.0001.jpg" or "doc.1887.82.jpg"
  # Parameter syntax reference:
  # https://iiif.io/api/image/2.1/#image-request-parameters
  def iiif(image,
           region: "full",
           size: APP_OPTS["thumbnail_size"],
           rotation: 0,
           quality: "default",
           format: "jpg")
    server = IIIF_PATH
    project = APP_OPTS["media_server_dir"]
    # use %2F for image specific path, / for iiif server path
    image_esc = image.gsub("/", "%2F")
    iiif_opts = "#{region}/#{size}/#{rotation}/#{quality}.#{format}"

    "#{server}/#{project}%2F#{image_esc}/#{iiif_opts}"
  end

  def locale
    I18n.locale
  end

  def locale_link(lang_code)
    locales = APP_OPTS["languages"].split("|")
      .reject { |l| l == APP_OPTS["language_default"] }.join("|")
    url = request.fullpath

    if lang_code == APP_OPTS["language_default"]
      if config.relative_url_root.present?
        regex = /^(#{config.relative_url_root})(?:\/(?:#{locales}))?(\/.*|$)/
        link_path = url.sub(regex, "\\1\\2")
      else
        regex = /(?:^\/(?:#{locales}))?(\/.*|$)/
        link_path = url.sub(regex, "\\1")

        # Handle edge case: request is for root of site on non-default locale
        link_path = "/" if link_path.empty?
      end
    else
      if config.relative_url_root.present?
        regex = /^(#{config.relative_url_root})(?:\/(?:#{locales}))?(\/.*|$)/
        link_path = url.sub(regex, "\\1/#{lang_code}\\2")
      else
        regex = /(?:^\/(?:#{locales}))?(\/.*|$)/
        link_path = url.sub(regex, "/#{lang_code}\\1")
      end
    end

    link_path
  end

  # partial_name does not include the locale, underscore, or extensions
  #   (ex: index, not _index_en.html.erb)
  # prefixes refers to the path to reach the partial in question
  #
  # Usage:
  #   render localized_partial("index", "explore/partials")
  #   (would include "explore/partials/_index_en.html.erb" if locale == en)
  # TODO remove this method when migrating orchid to rails 6
  deprecate localized_partial:
    "prefer localized views: https://guides.rubyonrails.org/i18n.html#localized-views"
  def localized_partial(partial_name, prefixes)
    localized = "#{partial_name}_#{locale}"
    if lookup_context.template_exists?(localized, prefixes, true)
      "#{prefixes}/#{localized}"
    else
      # fallback to informative partial about customization
      @missing_partial = "#{prefixes}/#{localized}"
      "errors/missing_partial"
    end
  end

  def prefix_path(path, *args, **kwargs)
    # Hash with rocket syntax `"f" => ["...|..."]` comes through in args here,
    # so merge into kwargs and empty args
    if args.length == 1 && args[0].is_a?(Hash)
      kwargs = kwargs.merge(args[0])
      args = []
    end

    path_helper = @section.present? ? "#{@section}_#{path}" : path

    if args.empty?
      if kwargs.empty?
        send(path_helper)
      else
        send(path_helper, kwargs)
      end
    else
      if kwargs.empty?
        send(path_helper, args)
      else
        send(path_helper, args, kwargs)
      end
    end
  end

  # Render section override and partials
  # partial argument does not include the locale, underscore, or extensions
  # Example:
  #   render_overridable("explore/partials", "index")
  #   Looks for in order:
  #     If @section defined -> "@section/_index.html.erb"
  #     If no @section -> "explore/partials/_index.html.erb"
  #  If no partial found, render an error message with missing partial path
  def render_overridable(path="", partial="", **kwargs)
    # Only one arg will be passed if replacing a simple `render "template"` call
    # In that case, set partial to arg value assigned to path and empty path
    if partial == ""
      partial = path
      # template_exists? still needs a path to search; lookup_context.prefixes
      # is what render code uses when only one arg, so assign it to path here
      path = lookup_context.prefixes
    end

    # If partial still empty (no args), use controller action as template name
    if partial == ""
      partial = params[:action]
    end

    # True when looking for partials rather than views
    is_partial = true

    if @section.present? && path.is_a?(String) &&
      lookup_context.template_exists?(partial, "#{@section}/#{path}",
                                      is_partial)
      path = "#{@section}/#{path}"
    elsif @section.present? && path.is_a?(Array) &&
      lookup_context.template_exists?(partial, "#{@section}/#{path[0]}",
                                      is_partial)
      path = "#{@section}/#{path[0]}"
    elsif !lookup_context.template_exists?(partial, path, is_partial)
      # fallback to informative partial about customization
      path << "/" if path.present?
      @missing_partial = "#{path}#{partial}"
      return render "errors/missing_partial", kwargs
    end

    # Revert earlier assignment of lookup_context.prefixes so render args are
    # same as simple call `render "template"` being overridden
    path = "" if path == lookup_context.prefixes

    path << "/" if path.present?
    render "#{path}#{partial}", kwargs
  end

  def site_section
    if @site_section.present?
      # Use override from instance variable
      section = @site_section
    else
      if current_page? home_path
        section = "home"
      elsif request.path[/^\/[^\/]+?\/.+/]
        # If request path has a sub-uri section (or namespacing),
        # use that part of the path (e.g. "browse" of "/browse/creator")
        section = request.path[/^\/([^\/]+?)\/.+/, 1]
      else
        # If path matches controller or action name, use that (e.g. "/about")
        if request.path[/^\/#{params["controller"]}$/]
          section = params["controller"]
        elsif request.path[/^\/#{params["action"]}$/]
          section = params["action"]
        else
          section = "pages"
        end
      end
    end

    " class=\"site_#{section}\"".html_safe
  end

end
