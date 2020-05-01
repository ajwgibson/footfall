class EnhanceDevicesWithFootfallAndBatteryValues < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :footfall, :integer
    add_column :devices, :battery, :integer
  end
end
