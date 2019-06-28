class ErrorsController < ApplicationController

  def not_found
    render_overridable(status: 404)
  end

  def server_error
    render_overridable(status: 500)
  end

end
