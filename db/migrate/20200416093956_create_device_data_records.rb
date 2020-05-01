class CreateDeviceDataRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :device_data_records do |t|
      t.string   :device_id, null: false
      t.integer  :footfall
      t.integer  :battery
      t.datetime :recorded_at
      t.timestamps
    end
  end
end
