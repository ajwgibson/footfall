# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :controller do
  login_user

  describe 'GET #index' do
    let(:devices) { double('devices') }
    before(:each) do
      allow(devices).to receive(:order_by).and_return(devices)
      allow(devices).to receive(:order).and_return(devices)
      allow(devices).to receive(:page).and_return(devices)
    end
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
    it 'populates an array of devices' do
      device = FactoryBot.create(:default_device)
      get :index
      expect(assigns(:devices)).to include(device)
    end
    it 'stores filters to the session' do
      get :index, params: { with_device_id: 'xxx' }
      expect(session[:filter_devices].except(:order_by)).to eq('with_device_id' => 'xxx')
    end
    it 'removes blank filter values' do
      get :index, params: { with_device_id: nil }
      expect(assigns(:filter).except(:order_by)).to eq({})
    end
    it 'retrieves filters from the session if none have been supplied' do
      a = FactoryBot.create(:default_device, device_id: 'xxx')
      FactoryBot.create(:default_device, device_id: 'yyy')
      get :index, params: {}, session: { filter_devices: { with_device_id: 'xxx' } }
      expect(assigns(:devices)).to eq([a])
    end
    it "applies a default 'order_by' if none is specified" do
      get :index, params: {}
      expect(session[:filter_devices]).to include(order_by: 'device_id')
    end
    it "applies the 'order_by' parameter" do
      b = FactoryBot.create(:default_device, device_id: 'b')
      a = FactoryBot.create(:default_device, device_id: 'a')
      c = FactoryBot.create(:default_device, device_id: 'c')
      get :index, params: { order_by: 'device_id desc' }
      expect(assigns(:devices)).to eq([c, b, a])
    end
    it "applies the 'with_device_id' filter" do
      expect(Device).to receive(:with_device_id).with('xxx').and_return(devices)
      get :index, params: { with_device_id: 'xxx' }
    end
    it "applies the 'with_device_group_id' filter" do
      expect(Device).to receive(:with_device_group_id).with('xxx').and_return(devices)
      get :index, params: { with_device_group_id: 'xxx' }
    end
    it "applies the 'with_battery_status' filter" do
      expect(Device).to receive(:with_battery_status).with('xxx').and_return(devices)
      get :index, params: { with_battery_status: 'xxx' }
    end
    it "applies the 'with_footfall_status' filter" do
      expect(Device).to receive(:with_footfall_status).with('xxx').and_return(devices)
      get :index, params: { with_footfall_status: 'xxx' }
    end
    it "applies the 'with_a_location' filter" do
      expect(Device).to receive(:with_a_location).with('true').and_return(devices)
      get :index, params: { with_a_location: true }
    end
    it "applies the 'with_device_type' filter" do
      expect(Device).to receive(:with_device_type).with('arduino').and_return(devices)
      get :index, params: { with_device_type: 'arduino' }
    end
    context 'applies paging' do
      before(:each) do
        Kaminari.configure do |config|
          @default_per_page = config.default_per_page
          config.default_per_page = 2
        end
      end
      after(:each) do
        Kaminari.configure do |config|
          config.default_per_page = @default_per_page
        end
      end
      context 'with no explicit page value' do
        it 'returns the first page of devices' do
          3.times { |_i| FactoryBot.create(:default_device) }
          get :index
          expect(assigns(:devices).count).to eq(2)
        end
      end
      context 'with an explicit page value' do
        it 'returns the requested page of devices' do
          3.times { |_i| FactoryBot.create(:default_device) }
          get :index, params: { page: 2 }
          expect(assigns(:devices).count).to eq(1)
        end
      end
    end
  end

  describe 'GET #clear_filter' do
    it 'redirects to #index' do
      get :clear_filter
      expect(response).to redirect_to(devices_path)
    end
    it 'clears the session entry' do
      session[:filter_devices] = { 'with_device_id' => 'xxx' }
      get :clear_filter
      expect(session.key?(:filter_devices)).to be false
    end
  end

  describe 'GET #show' do
    let(:device) { FactoryBot.create(:default_device) }
    it 'shows a record' do
      get(:show, params: { id: device.id })
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:device).id).to eq(device.id)
      expect(assigns(:title)).to eq('Device details')
    end
    it 'raises an exception for a missing record' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:show, params: { id: 99 })
      end
    end
  end

  describe 'GET #new' do
    let(:device_groups) { double }
    before(:each) do
      allow(DeviceGroup).to receive(:ordered_by_name).and_return(device_groups)
      get :new
    end
    it 'renders a blank form' do
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:device).id).to be_nil
      expect(assigns(:title)).to eq('New device')
      expect(assigns(:cancel_path)).to eq(devices_path)
    end
    it 'includes a list of device groups' do
      expect(assigns(:device_groups)).to eq(device_groups)
    end
  end

  describe 'POST #create' do
    let(:device_group) { FactoryBot.create(:default_device_group) }
    context 'with valid data' do
      let(:device) { Device.order(:id).last }
      def post_create
        attrs = {
          device_id: 'xxx',
          latitude: 1.23,
          longitude: 2.34,
          footfall_threshold_amber: 1,
          footfall_threshold_red: 2,
          battery_threshold_amber: 4,
          battery_threshold_red: 3,
          notes: 'Some notes',
          device_group_id: device_group.id,
          footfall: 10,
          battery: 11,
          device_type: :arduino
        }
        post(:create, params: { device: attrs })
      end
      before(:each) do
        post_create
      end
      it 'creates a new record' do
        expect do
          post(:create, params: { device: FactoryBot.attributes_for(:default_device) })
        end.to change(Device, :count).by(1)
      end
      it 'redirects to the show action' do
        expect(response).to redirect_to(device_path(device))
      end
      it 'set a flash message' do
        expect(flash[:notice]).to eq('Device was created successfully')
      end
      it 'stores the device_id' do
        expect(device.device_id).to eq('xxx')
      end
      it 'stores the latitude' do
        expect(device.latitude).to eq(1.23)
      end
      it 'stores the longitude' do
        expect(device.longitude).to eq(2.34)
      end
      it 'stores the footfall_threshold_amber' do
        expect(device.footfall_threshold_amber).to eq(1)
      end
      it 'stores the footfall_threshold_red' do
        expect(device.footfall_threshold_red).to eq(2)
      end
      it 'stores the battery_threshold_amber' do
        expect(device.battery_threshold_amber).to eq(4)
      end
      it 'stores the battery_threshold_red' do
        expect(device.battery_threshold_red).to eq(3)
      end
      it 'stores the notes' do
        expect(device.notes).to eq('Some notes')
      end
      it 'stores the device group' do
        expect(device.device_group).to eq(device_group)
      end
      it 'stores the footfall' do
        expect(device.footfall).to eq(10)
      end
      it 'stores the battery' do
        expect(device.battery).to eq(11)
      end
      it 'stores the device type' do
        expect(device.arduino?).to be_truthy
      end
    end
    context 'with invalid data' do
      def post_create
        attrs = FactoryBot.attributes_for(:device, device_id: 'A')
        post(:create, params: { device: attrs })
      end
      it 'does not create a new record' do
        expect do
          post_create
        end.to_not change(Device, :count)
      end
      it 're-renders the form with the posted data and title' do
        post_create
        expect(response).to render_template(:edit)
        expect(assigns(:device).device_id).to eq('A')
        expect(assigns(:title)).to eq('New device')
        expect(assigns(:cancel_path)).to eq(devices_path)
      end
    end
  end

  describe 'GET #edit' do
    let(:device) { FactoryBot.create(:default_device) }
    it 'shows a record for editing' do
      get(:edit, params: { id: device.id })
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:device).id).to eq(device.id)
      expect(assigns(:title)).to eq('Edit device details')
      expect(assigns(:cancel_path)).to eq(device_path(device))
    end
    it 'raises an exception for a missing record' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:edit, params: { id: 99 })
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid data' do
      let(:device) { FactoryBot.create(:default_device, device_id: 'Original') }
      def post_update
        put(:update,
            params: {
              id: device.id,
              device: {
                device_id: 'Changed'
              }
            })
        device.reload
      end
      before(:each) do
        post_update
      end
      it 'updates the device details' do
        expect(device.device_id).to eq('Changed')
      end
      it 'redirects to the show action' do
        expect(response).to redirect_to(device_path(assigns(:device)))
      end
      it 'sets a flash message' do
        expect(flash[:notice]).to eq('Device was updated successfully')
      end
    end
    context 'with invalid data' do
      let(:device) { FactoryBot.create(:default_device, device_id: 'Original') }
      def post_update
        put(:update, params: { id: device.id, device: { device_id: '' } })
        device.reload
      end
      before(:each) do
        post_update
      end
      it 'does not update the device details' do
        expect(device.device_id).to eq('Original')
      end
      it 're-renders the form with the posted data' do
        expect(response).to render_template(:edit)
        expect(assigns(:device).device_id).to eq('')
        expect(assigns(:title)).to eq('Edit device details')
        expect(assigns(:cancel_path)).to eq(device_path(device))
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:device) { FactoryBot.create(:default_device) }
    it 'deletes the record' do
      expect do
        delete(:destroy, params: { id: device.id })
      end.to change(Device, :count).by(-1)
    end
    it 'redirects to #index' do
      delete(:destroy, params: { id: device.id })
      expect(response).to redirect_to(devices_path)
    end
  end
end
