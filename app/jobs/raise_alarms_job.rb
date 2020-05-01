class RaiseAlarmsJob < ApplicationJob
  queue_as :default

  def perform(background_task)
    background_task.start

    records = []

    Device.all.each do |device|
      data = DeviceDataRecord
        .with_device_id(device.device_id)
        .order(recorded_at: :desc)
        .limit(96)
        .to_ary

      next unless data.count > 0

      max_footfall = data.max_by { |d| d.footfall }.footfall
      footfall_alarm = device.raise_footfall_alarm(max_footfall)

      min_battery  = data.min_by { |d| d.battery }.battery
      battery_alarm = device.raise_battery_alarm(min_battery)

      records << {
        device_id: device.device_id,
        raised_footfall_alarm: footfall_alarm,
        raised_battery_alarm: battery_alarm
      }
    end

    background_task.update(
      info: {
        devices: {
          count: records.count,
          records: records
        }
      }
    )

    background_task.finish :success
  end
end
