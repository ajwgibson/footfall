class DeviceGroup < ApplicationRecord

  include Filterable

  has_paper_trail

  has_many :devices, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  scope :ordered_by_name, -> { order(:name) }
  scope :with_name, ->(value) { where('lower(name) like lower(?)', "%#{value}%")}

  def device_count
    devices.count
  end

  def map_centre
    settings = Settings.current

    points =
      self
      .devices
      .with_a_location(true)
      .map { |d| {latitude: d.latitude, longitude: d.longitude} }

    points = [
      {
        latitude: settings.default_latitude,
        longitude: settings.default_longitude
      }
    ] if points.count == 0

    return MappingService.find_center_point(points)
  end

  def map_zoom
    settings = Settings.current
    devices = self.devices.with_a_location(true)
    devices.count == 0 ? settings.default_zoom_no_location : settings.default_zoom_specific_location
  end
end
