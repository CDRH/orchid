class ErrorsController < ApplicationController

  def not_found
    render :status => 404
  end

  def server_error
    render :status => 500
  end

end
