# frozen_string_literal: true

module DeviceDataRecordsHelper
  def device_data_record_status(ddr)
    ddr.status.humanize.upcase
  end
end
