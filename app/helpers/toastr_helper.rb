# frozen_string_literal: true
# rubocop:disable all

#
# Toastr messages used for application flashes
#
module ToastrHelper

  unless const_defined?(:ALERT_TYPES)
    ALERT_TYPES = %i[success info warning error].freeze
  end


  def toastr_flash
    flash_messages = []

    flash.each do |type, message|
      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :info    if type == :alert

      next unless ALERT_TYPES.include? type

      Array(message).each do |msg|
        text = content_tag(
          :div, msg,
          'data-toastr-type' => type,
          :class => 'toastr-message hidden'
        )
        flash_messages << text if msg
      end
    end

    flash_messages.join("\n").html_safe
  end

end

# rubocop:enable all
