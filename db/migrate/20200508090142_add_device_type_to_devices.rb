class AddDeviceTypeToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :device_type, :integer, null: false, default: 0
  end
end
