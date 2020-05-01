# frozen_string_literal: true

class Audit < PaperTrail::Version
  include Filterable

  scope :for_event,     ->(value) { where event: value }
  scope :for_item_type, ->(value) { where item_type: value }
  scope :for_item_id,   ->(value) { where item_id: value }
  scope :for_whodunnit, ->(value) { where('lower(whodunnit) like lower(?)', "%#{value}%") }
  scope :for_date,      ->(value) { where('date(created_at) = ?', value) }

  SELECTABLE_EVENT_TYPES = [
    %w[CREATE create],
    %w[UPDATE update],
    %w[DESTROY destroy]
  ].freeze

  def humanized_item_type
    Audit.humanize item_type
  end

  def self.humanize(value)
    value.underscore.humanize
  end

  def self.selectable_item_types
    Audit.distinct.order(:item_type).pluck(:item_type)
  end
end
