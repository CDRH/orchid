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

  def copy_params
    # Remove Rails internal parameters "action" and "controller" from URLs
    # They are always accessible via params["action"] and params["controller"]
    return params.to_unsafe_h
             .reject { |param| param[/^(?:action|controller)$/] }
  end

  def clear_search_text
    new_params = copy_params
    new_params.delete("q")

    # Prevent relevancy sort remaining if one clicks "Clear Search Text" link
    if params["sort"].present? && params["sort"].first == "relevancy|desc"
      new_params.delete("sort")
    end

    return new_params
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

    return " class=\"site_#{section}\"".html_safe
  end

end
