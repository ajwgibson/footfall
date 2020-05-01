# frozen_string_literal: true
# rubocop:disable all

module SortableHelper
  def sortable(column, filter, path, title = nil)
    title ||= column.titleize

    current_order_by = filter.fetch(:order_by, '')

    is_current = (column == current_order_by.gsub(' desc', ''))
    is_descending = current_order_by.include?('desc')

    filter = filter.except(:order_by, :page)

    filter[:page] = 1
    filter[:order_by] = column
    filter[:order_by] = (column.split(',').map { |x| x + ' desc' }).join(',') if is_current && !is_descending

    css_class = 'mr-1 fa fa-sort'
    css_class += '-down text-danger' if is_current && !is_descending
    css_class += '-up text-danger' if is_current && is_descending

    href = "#{path}?#{filter.to_query}"

    content_tag :a, href: href do
      concat(content_tag(:i, ' ', class: css_class))
      concat("#{title} ")
    end
  end
end

# rubocop:enable all
