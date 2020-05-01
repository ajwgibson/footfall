class Alarm < ApplicationRecord

  include Filterable

  has_paper_trail

  belongs_to :device

  enum alarm_type: %i[ footfall battery ]
  enum status: %i[ active cleared ]
  enum level: %i[ amber red ]

  # VALIDATION
  validates :value, numericality: { only_integer: true, greater_than: 0 }
  validates :threshold, numericality: { only_integer: true, greater_than: 0 }

  # SCOPES
  scope :with_device_id, ->(value) {
    joins(:device)
    .where('lower(devices.device_id) like lower(?)', "%#{value}%")
  }

  scope :with_alarm_type, ->(value) { where(alarm_type: value) }
  scope :with_status, ->(value) { where(status: value) }
  scope :with_level, ->(value) { where(level: value) }

  # METHODS
  def self.selectable_alarm_types
    Alarm.alarm_types.keys.map { |r| [r.humanize, r] }
  end

  def self.selectable_statuses
    Alarm.statuses.keys.map { |r| [r.humanize, r] }
  end

  def self.selectable_levels
    Alarm.levels.keys.map { |r| [r.humanize, r] }
  end
end
