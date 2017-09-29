module Orchid::ApplicationHelper

  def copy_params
    # Remove Rails internal parameters "action" and "controller" from URLs
    # They are always accessible via params["action"] and params["controller"]
    return params.to_unsafe_h
             .reject { |param| param[/^(?:action|controller)$/] }
  end

  def clear_search_text
    new_params = copy_params
    new_params.delete("q")
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
