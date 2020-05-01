class UpdateDeviceCountersJob < ApplicationJob
  queue_as :default

  def perform(background_task)
    background_task.start

    updates = []
    skips = []

    Device.all.each do |device|
      data = DeviceDataRecord
        .with_device_id(device.device_id)
        .order(recorded_at: :desc)
        .first

      if data.present?
        device.update(
          footfall: data.footfall,
          battery: data.battery
        )

        updates << {
          device_id: device.device_id,
          footfall: data.footfall,
          battery: data.battery
        }
      else
        skips << {
          device_id: device.device_id
        }
      end
    end

    background_task.update(
      info: {
        updates: {
          count: updates.count,
          records: updates
        },
        skips: {
          count: skips.count,
          records: skips
        }
      }
    )

    background_task.finish :success
  end
end
