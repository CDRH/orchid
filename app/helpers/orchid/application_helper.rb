module Orchid::ApplicationHelper

  def copy_params
    return params.to_unsafe_h
  end

  def clear_search_text
    new_params = copy_params
    # TODO also remove qfield from here if that is implemented
    new_params.delete("q")
    return new_params
  end

end
