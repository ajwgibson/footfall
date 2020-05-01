class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.integer :default_footfall_threshold_amber, null: false
      t.integer :default_footfall_threshold_red,   null: false
      t.integer :default_battery_threshold_amber,  null: false
      t.integer :default_battery_threshold_red,    null: false

      t.timestamps
    end
  end
end
