class RetrieveFootfallDataJob < ApplicationJob
  queue_as :default

  def perform(background_task)
    background_task.start

    service = DynamoDbService.new

    additions = []
    duplicates = []
    errors = []

    records = service.get_footfall_data

    records.each do |record|
      begin
        params = {
          device_id: record[:dev_id],
          footfall: record[:footfall],
          battery: record[:battery],
          recorded_at: record[:time].to_time
        }

        if DeviceDataRecord.exists?(params)
          duplicates << record
        else
          DeviceDataRecord.create(params)
          additions << record
        end

        service.delete_footfall_data(record)
      rescue => e
        record[:error] = {
          type: e.exception_type,
          message: e.message
        }
        errors << record
      end
    end

    background_task.update(
      info: {
        retrieved: records.count,
        additions: {
          count: additions.count,
          records: additions
        },
        duplicates: {
          count: duplicates.count,
          records: duplicates
        },
        errors: {
          count: errors.count,
          records: errors
        }
      }
    )

    background_task.finish :success

    BackgroundTask.schedule_update_device_counters_task
    BackgroundTask.schedule_raise_alarms_task
  end
end
