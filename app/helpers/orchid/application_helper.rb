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

end
