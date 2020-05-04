class Device < ApplicationRecord

  include Filterable

  has_paper_trail

  belongs_to :device_group, optional: true
  has_many :alarms, dependent: :destroy

  # CALLBACKS
  before_save :reorder_thresholds

  # VALIDATION
  validates :device_id, presence: true, uniqueness: true

  validates :footfall_threshold_amber, numericality: {
    only_integer: true, greater_than: 0, less_than: 65536
  }

  validates :footfall_threshold_red, numericality: {
    only_integer: true, greater_than: 0, less_than: 65536
  }

  validates :battery_threshold_amber, numericality: {
    only_integer: true, greater_than: 0, less_than: 100
  }

  validates :battery_threshold_red, numericality: {
    only_integer: true, greater_than: 0, less_than: 100
  }

  # SCOPES
  scope :ordered_by_device_id, -> { order(:device_id) }
  scope :with_device_id, ->(value) { where('lower(device_id) like lower(?)', "%#{value}%")}
  scope :with_device_group_id, ->(value) { where(device_group_id: value) }

  def self.with_battery_status(value)
    return Device.where('battery > battery_threshold_amber') if 'green'.eql?(value)

    if 'amber'.eql?(value)
      return Device.where('battery > battery_threshold_red and battery <= battery_threshold_amber')
    end

    Device.where('battery <= battery_threshold_red')
  end

  def self.with_footfall_status(value)
    return Device.where('footfall < footfall_threshold_amber') if 'green'.eql?(value)

    if 'amber'.eql?(value)
      return Device.where(
        'footfall < footfall_threshold_red and footfall >= footfall_threshold_amber'
      )
    end

    Device.where('footfall >= footfall_threshold_red')
  end

  def self.with_a_location(value)
    value = value.to_s.downcase == "true"
    return Device.where.not(latitude: nil).where.not(longitude: nil) if value
    Device.where(latitude: nil).or(where(longitude: nil))
  end

  # METHODS
  def self.status_values
    ['red', 'amber', 'green']
  end

  def self.new_device
    settings = Settings.current
    Device.new(
      battery_threshold_red:    settings.default_battery_threshold_red,
      battery_threshold_amber:  settings.default_battery_threshold_amber,
      footfall_threshold_red:   settings.default_footfall_threshold_red,
      footfall_threshold_amber: settings.default_footfall_threshold_amber
    )
  end

  def location_as_string
    "#{latitude}, #{longitude}" unless latitude.blank? || longitude.blank?
  end

  def footfall_red?
    return false unless footfall
    return true if footfall >= footfall_threshold_red
    false
  end

  def footfall_amber?
    return false unless footfall
    return false if footfall < footfall_threshold_amber
    return false if footfall >= footfall_threshold_red
    true
  end

  def footfall_green?
    return false unless footfall
    return true if footfall < footfall_threshold_amber
    false
  end

  def battery_red?
    return false unless battery
    return true if battery <= battery_threshold_red
    false
  end

  def battery_amber?
    return false unless battery
    return false if battery > battery_threshold_amber
    return false if battery <= battery_threshold_red
    true
  end

  def battery_green?
    return false unless battery
    return true if battery > battery_threshold_amber
    false
  end

  def colour
    return 'red' if self.footfall_red? || self.battery_red? || self.alarms.active.red.any?
    return 'orange' if self.footfall_amber? || self.battery_amber? || self.alarms.active.amber.any?
    return 'green'
  end

  def raise_footfall_alarm(footfall)
    return false if footfall.nil?
    return false if self.alarms.active.footfall.red.count > 0

    if footfall > self.footfall_threshold_red
      self.alarms.create(
        alarm_type: :footfall,
        level: :red,
        value: footfall,
        threshold: self.footfall_threshold_red
      )
      return true
    end

    return false if self.alarms.active.footfall.amber.count > 0

    if footfall > self.footfall_threshold_amber
      self.alarms.create(
        alarm_type: :footfall,
        level: :amber,
        value: footfall,
        threshold: self.footfall_threshold_amber
      )
      return true
    end

    return false
  end

  def raise_battery_alarm(battery)
    return false if battery.nil?
    return false if self.alarms.active.battery.red.count > 0

    if battery < self.battery_threshold_red
      self.alarms.create(
        alarm_type: :battery,
        level: :red,
        value: battery,
        threshold: self.battery_threshold_red
      )
      return true
    end

    return false if self.alarms.active.battery.amber.count > 0

    if battery < self.battery_threshold_amber
      self.alarms.create(
        alarm_type: :battery,
        level: :amber,
        value: battery,
        threshold: self.battery_threshold_amber
      )
      return true
    end

    return false
  end

  def graph_id
    "#{self.device_id}-footfall-graph"
  end

  def graph_data
    DeviceDataRecord
        .with_device_id(self.device_id)
        .where('recorded_at > ?', 24.hours.ago)
        .order(recorded_at: :desc)
        .reverse
  end

  private

  def reorder_thresholds
    if self.battery_threshold_amber < self.battery_threshold_red
      self.battery_threshold_red, self.battery_threshold_amber =
        self.battery_threshold_amber, self.battery_threshold_red
    end

    if self.footfall_threshold_amber > self.footfall_threshold_red
      self.footfall_threshold_red, self.footfall_threshold_amber =
        self.footfall_threshold_amber, self.footfall_threshold_red
    end
  end

end
