class CreateAlarms < ActiveRecord::Migration[5.2]
  def change
    create_table :alarms do |t|
      t.belongs_to :device, null: false, index: true
      t.integer :alarm_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :level, null: false, default: 0
      t.integer :value, null: false
      t.integer :threshold, null: false
      t.timestamps
    end
  end
end
