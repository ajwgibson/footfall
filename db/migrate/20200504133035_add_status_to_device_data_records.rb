class AddStatusToDeviceDataRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :device_data_records, :status, :integer, null: false, default: 0
  end
end
