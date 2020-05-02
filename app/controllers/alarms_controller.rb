# frozen_string_literal: true

class AlarmsController < ApplicationController
  load_and_authorize_resource

  def index
    @filter = get_filter
    @title = 'Alarms'
    @alarms = Alarm.joins(:device).filter(@filter).order('alarms.created_at desc')
    @alarms = @alarms.page(params[:page])
    set_filter @filter
  end

  def clear_filter
    set_filter nil
    redirect_to alarms_path
  end

  def show
    @title = 'Alarm details'
  end

  def clear
    @alarm.cleared!
    redirect_to alarm_path(@alarm), notice: 'Alarm was cleared'
  end

  def clear_many
    before = Alarm.cleared.count
    Alarm.active.where(id: params[:alarm_ids]).each { |a| a.cleared! }
    count = Alarm.cleared.count - before
    redirect_to alarms_path, notice: "#{count} #{'alarm'.pluralize(count)} cleared"
  end

  private

  def get_filter
    filter =
      params
      .permit(
        :order_by,
        :with_status,
        :with_alarm_type,
        :with_level,
        :with_device_id
      ).to_h
    filter = session[:filter_alarms].symbolize_keys! if filter.empty? && session.key?(:filter_alarms)
    filter[:order_by] = 'alarms.created_at desc' unless filter.key?(:order_by)
    filter.delete_if { |_key, value| value.blank? }
  end

  def set_filter(filter)
    session[:filter_alarms] = filter unless filter.nil?
    session.delete(:filter_alarms) if filter.nil?
  end
end
