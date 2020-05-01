class HomeController < ApplicationController
  def dashboard
    @title = "Dashboard"

    @interval = get_interval_setting

    @alarms = Alarm.active.count

    @footfall_red   = Device.with_footfall_status('red').count
    @footfall_amber = Device.with_footfall_status('amber').count
    @footfall_green = Device.with_footfall_status('green').count

    @battery_red   = Device.with_battery_status('red').count
    @battery_amber = Device.with_battery_status('amber').count
    @battery_green = Device.with_battery_status('green').count

    @devices_to_mark = Device.with_a_location(true)

    respond_to do |format|
      format.html
      format.json {
        render json: {
          'alarms':         @alarms,
          'footfall_red':   @footfall_red,
          'footfall_amber': @footfall_amber,
          'footfall_green': @footfall_green,
          'battery_red':    @battery_red,
          'battery_amber':  @battery_amber,
          'battery_green':  @battery_green,
        }.to_json
      }
    end
  end

  private

  def get_interval_setting
    interval = 30000
    interval = session[:dashboard_interval] if session.key?(:dashboard_interval)
    interval = params[:interval].to_i if params.include?(:interval)
    interval = -1    if interval < 10000
    interval = 60000 if interval > 60000
    session[:dashboard_interval] = interval
    interval
  end
end
