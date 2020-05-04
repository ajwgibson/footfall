class DeviceDataRecord < ApplicationRecord

  include Filterable

  has_paper_trail

  enum status: %i[ collected processed ]

  # VALIDATION
  validates :device_id, presence: true

  # SCOPES
  scope :with_device_id, ->(value) { where('lower(device_id) like lower(?)', "%#{value}%")}
  scope :recorded_on, ->(value) { where('date(recorded_at) = ?', value) }
  scope :with_status, ->(value) { where(status: value) }

  # METHODS
  def self.selectable_statuses
    DeviceDataRecord.statuses.keys.map { |r| [r.humanize, r] }
  end
end
