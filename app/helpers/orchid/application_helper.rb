module Orchid::ApplicationHelper

  def copy_params
    return params.to_unsafe_h
  end

  def clear_search_text
    new_params = copy_params
    new_params.delete("q")
    return new_params
  end

end
