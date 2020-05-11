class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  before_action :get_current_settings

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name])
  end

  def user_for_paper_trail
    user_signed_in? ? current_user.full_name : 'Not logged in'
  end

  def fix_filter_dates(filter, key, direction = :to_date)
    return if filter.nil?
    return unless filter.include? key

    fix_filter_dates_to_date(filter, key) if direction == :to_date
    fix_filter_dates_to_string(filter, key) if direction == :to_string
  end

  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to(controller: 'errors', action: 'not_authorized')
  end

  private

  def get_current_settings
    @settings = Settings.current
  end

  def fix_filter_dates_to_date(filter, key)
    filter[key] = Date.strptime(filter[key], '%d/%m/%Y') unless filter[key].blank?
  end

  def fix_filter_dates_to_string(filter, key)
    filter[key] = filter[key].strftime('%d/%m/%Y') unless filter[key].nil?
  end
end
