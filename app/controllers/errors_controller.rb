class ErrorsController < ApplicationController

  def not_found
    render(status: 404)
  end

  def server_error
    # Log the error
    Rails.logger.error "Server Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    render(status: 500)
  end

end
