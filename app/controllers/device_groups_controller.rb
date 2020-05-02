# frozen_string_literal: true

class DeviceGroupsController < ApplicationController
  load_and_authorize_resource

  def index
    @filter = get_filter
    @title = 'Device groups'
    @device_groups = DeviceGroup.filter(@filter).order(:name)
    @device_groups = @device_groups.page(params[:page])
    set_filter @filter
  end

  def clear_filter
    set_filter nil
    redirect_to device_groups_path
  end

  def show
    @title = 'Device group details'
    @alarms =
      Alarm
        .joins(:device)
        .active
        .where(alarms: { device_id: @device_group.devices.collect { |d| d.id } })
        .order('devices.device_id')
  end

  def new
    @device_group = DeviceGroup.new
    @title = 'New device group'
    @cancel_path = device_groups_path
    render :edit
  end

  def create
    @device_group = DeviceGroup.new device_group_params
    if @device_group.save
      redirect_to(device_group_path(@device_group), notice: 'Device group was created successfully')
    else
      @title       = 'New device group'
      @cancel_path = device_groups_path
      render :edit
    end
  end

  def edit
    @title = 'Edit device group details'
    @cancel_path = device_group_path(@device_group)
  end

  def update
    if @device_group.update device_group_params
      redirect_to device_group_path(@device_group), notice: 'Device group was updated successfully'
    else
      @title       = 'Edit device group details'
      @cancel_path = device_group_path(@device_group)
      render :edit
    end
  end

  def destroy
    @device_group.destroy
    redirect_to device_groups_path, notice: 'Device group was deleted'
  end

  private

  def device_group_params
    params
      .require(:device_group)
      .permit(
        :name,
        :notes
      )
  end

  def get_filter
    filter =
      params
      .permit(
        :order_by,
        :with_name
      ).to_h
    filter = session[:filter_device_groups].symbolize_keys! if filter.empty? && session.key?(:filter_device_groups)
    filter[:order_by] = 'name' unless filter.key?(:order_by)
    filter.delete_if { |_key, value| value.blank? }
  end

  def set_filter(filter)
    session[:filter_device_groups] = filter unless filter.nil?
    session.delete(:filter_device_groups) if filter.nil?
  end
end
