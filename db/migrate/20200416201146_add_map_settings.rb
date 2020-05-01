class AddMapSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :default_latitude, :decimal, precision: 10, scale: 6, null: false, default: 54.607577
    add_column :settings, :default_longitude, :decimal, precision: 10, scale: 6, null: false, default: -6.693145
    add_column :settings, :default_zoom_no_location, :integer, null: false, default: 8
    add_column :settings, :default_zoom_specific_location, :integer, null: false, default: 12
  end
end
