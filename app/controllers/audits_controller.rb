# frozen_string_literal: true

class AuditsController < ApplicationController
  load_and_authorize_resource

  def index
    @title = 'Audited events'
    @filter = get_filter
    @audits = Audit.filter(@filter)
    @audits = @audits.page(params[:page])
    set_filter @filter
  end

  def clear_filter
    set_filter nil
    redirect_to audits_path
  end

  def show
    @title = 'Audited event details'
  end

  private

  def get_filter
    filter =
      params
      .permit(
        :order_by,
        :for_event,
        :for_item_type,
        :for_item_id,
        :for_whodunnit,
        :for_date
      ).to_h
    if filter.empty? && session.key?(:filter_audits)
      filter = session[:filter_audits].symbolize_keys!
    end
    filter = { order_by: 'created_at desc' } if filter.empty?
    filter.delete_if { |_key, value| value.blank? }
  end

  def set_filter(filter)
    session[:filter_audits] = filter unless filter.nil?
    session.delete(:filter_audits) if filter.nil?
  end
end
