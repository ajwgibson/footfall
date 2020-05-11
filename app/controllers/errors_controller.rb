class ErrorsController < ApplicationController
  def not_authorized
    render 'errors/403'
  end

  def not_found
    render 'errors/404'
  end

  def internal_error
    render 'errors/500'
  end
end
