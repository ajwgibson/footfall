# frozen_string_literal: true

module AlarmsHelper
  def alarm_type_label(alarm)
    icon = alarm.battery? ? 'fa-battery-half' : 'fa-shoe-prints'
    content_tag(:span) do
      content_tag(:i, ' ', class: ['fas', icon]) + ' ' + alarm.alarm_type.humanize
    end
  end

  def alarm_status_label(alarm)
    style = alarm.active? ? 'label-danger' : 'label-success'
    content_tag(:span, class: ['label', style]) do
      alarm.status.humanize.upcase
    end
  end

  def alarm_level_label(alarm)
    style = alarm.red? ? 'label-danger' : 'label-warning'
    content_tag(:span, class: ['label', style]) do
      alarm.level.humanize.upcase
    end
  end
end
