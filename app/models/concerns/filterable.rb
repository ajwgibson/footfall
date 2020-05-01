# frozen_string_literal: true

module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = where(nil)
      filtering_params.each do |key, value|
        results = results.public_send(key, value) if value.present?
      end
      results
    end

    def order_by(value)
      null_ordering = value.include?('desc') ? ' nulls last' : ' nulls first'
      clause = (value.split(',').map { |x| x + null_ordering }).join(',')
      order(clause)
    end
  end
end
