class LinkDevicesToDeviceGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference :devices, :device_group, null: true, index: true, foreign_key: true
  end
end
