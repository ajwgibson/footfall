class CreateDeviceGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :device_groups do |t|
      t.string  :name, null: false, index: { unique: true }
      t.text    :notes
      t.timestamps
    end
  end
end
