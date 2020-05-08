# frozen_string_literal: true

class DeviceDataRecordsController < ApplicationController
  load_and_authorize_resource

  def index
    @filter = get_filter
    @title = 'Device records'
    @device_data_records = DeviceDataRecord.filter(@filter).order(:device_id)
    @device_data_records = @device_data_records.page(params[:page])
    set_filter @filter
  end

  def clear_filter
    set_filter nil
    redirect_to device_data_records_path
  end

  def destroy
    @device_data_record.destroy
    redirect_to device_data_records_path, notice: 'Device record was deleted'
  end

  private

  def get_filter
    filter =
      params
      .permit(
        :order_by,
        :with_device_id,
        :recorded_on,
        :with_status
      ).to_h

    if filter.empty? && session.key?(:filter_device_data_records)
      filter = session[:filter_device_data_records].symbolize_keys!
    end

    filter_dates.each { |d| fix_filter_dates(filter, d, :to_date) }
    filter[:order_by] = 'recorded_at desc' unless filter.key?(:order_by)
    filter.delete_if { |_key, value| value.blank? }
  end

  def set_filter(filter)
    if filter.nil?
      session.delete(:filter_device_data_records)
    else
      filter_dates.each { |d| fix_filter_dates(filter, d, :to_string) }
      session[:filter_device_data_records] = filter
    end
  end

  def filter_dates
    %i[
      recorded_on
    ]
  end
end
