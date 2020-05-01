class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string  :device_id, null: false, index: { unique: true }
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :footfall_threshold_amber, null: false
      t.integer :footfall_threshold_red, null: false
      t.integer :battery_threshold_amber, null: false
      t.integer :battery_threshold_red, null: false
      t.text    :notes
      t.timestamps
    end
  end
end
