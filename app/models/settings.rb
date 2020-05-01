class Settings < ApplicationRecord

  has_paper_trail

  validates :default_footfall_threshold_amber, numericality: {
    only_integer: true, greater_than: 0, less_than: 65536
  }

  validates :default_footfall_threshold_red, numericality: {
    only_integer: true, greater_than: 0, less_than: 65536
  }

  validates :default_battery_threshold_amber, numericality: {
    only_integer: true, greater_than: 0, less_than: 100
  }

  validates :default_battery_threshold_red, numericality: {
    only_integer: true, greater_than: 0, less_than: 100
  }

  validates :default_latitude, numericality: {
    greater_than_or_equal_to: -90, less_than_or_equal_to: 90
  }

  validates :default_longitude, numericality: {
    greater_than_or_equal_to: -180, less_than_or_equal_to: 180
  }

  validates :default_zoom_no_location, numericality: {
    only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 18
  }

  validates :default_zoom_specific_location, numericality: {
    only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 18
  }

  def self.current
    Settings.last || Settings.new
  end

end
