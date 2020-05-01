class DeviceDataRecord < ApplicationRecord

  include Filterable

  has_paper_trail

  # VALIDATION
  validates :device_id, presence: true

  # SCOPES
  scope :with_device_id, ->(value) { where('lower(device_id) like lower(?)', "%#{value}%")}
  scope :recorded_on, ->(value) { where('date(recorded_at) = ?', value) }

end
