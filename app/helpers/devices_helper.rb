# frozen_string_literal: true

module DevicesHelper
  def device_battery_status(device)
    return '' unless device.battery.present?

    style = 'text-green'
    battery = 'fa-battery-full'

    if device.battery_amber?
      style = 'text-warning'
      battery = 'fa-battery-half'
    end

    if device.battery_red?
      style = 'text-danger'
      battery = 'fa-battery-empty'
    end

    content_tag(:span, class: [style]) do
      content_tag(:i, ' ', class: ['fas', battery]) +
      " #{device.battery}%"
    end
  end

  def device_footfall_status(device)
    return '' unless device.footfall.present?

    style = 'text-green'
    style = 'text-warning' if device.footfall_amber?
    style = 'text-danger' if device.footfall_red?

    content_tag(:span, class: [style]) do
      content_tag(:i, ' ', class: ['fas', 'fa-shoe-prints']) +
      " #{device.footfall}"
    end
  end

  def device_map_icon_url(device)
    return "http://maps.google.com/mapfiles/ms/icons/#{device.colour}-dot.png"
  end
end
