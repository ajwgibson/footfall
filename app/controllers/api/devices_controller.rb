module Api
  class DevicesController < ApplicationController
    load_and_authorize_resource

    def index
      devices = Device.all unless params[:device_id].present?
      devices = Device.with_device_id(params[:device_id]) if params[:device_id].present?
      devices = devices.ordered_by_device_id
      render json: devices, each_serializer: DeviceSearchSerializer
    end
  end
end