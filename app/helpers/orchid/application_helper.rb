module Orchid::ApplicationHelper

  def copy_params
    return params.to_unsafe_h
  end

end
