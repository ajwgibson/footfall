# frozen_string_literal: true

module AuditsHelper
  def audit_event_label(event)
    event.upcase!
    style = 'info'
    style = 'danger'  if event == 'DESTROY'
    style = 'success' if event == 'CREATE'
    small_label(style, event)
  end

  def audits_path_for(item)
    audits_path(for_item_type: item.class.name, for_item_id: item.id)
  end

  private

  def small_label(style, label)
    content_tag(:small) do
      content_tag(:span, class: "label label-#{style}") do
        label
      end
    end
  end
end
