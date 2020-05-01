# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviceGroupsController, type: :controller do
  login_user

  describe 'GET #index' do
    let(:device_groups) { double('device_groups') }
    before(:each) do
      allow(device_groups).to receive(:order_by).and_return(device_groups)
      allow(device_groups).to receive(:order).and_return(device_groups)
      allow(device_groups).to receive(:page).and_return(device_groups)
    end
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
    it 'populates an array of device_groups' do
      device_group = FactoryBot.create(:default_device_group)
      get :index
      expect(assigns(:device_groups)).to include(device_group)
    end
    it 'stores filters to the session' do
      get :index, params: { with_name: 'xxx' }
      expect(session[:filter_device_groups].except(:order_by)).to eq('with_name' => 'xxx')
    end
    it 'removes blank filter values' do
      get :index, params: { with_name: nil }
      expect(assigns(:filter).except(:order_by)).to eq({})
    end
    it 'retrieves filters from the session if none have been supplied' do
      a = FactoryBot.create(:default_device_group, name: 'xxx')
      FactoryBot.create(:default_device_group, name: 'yyy')
      get :index, params: {}, session: { filter_device_groups: { with_name: 'xxx' } }
      expect(assigns(:device_groups)).to eq([a])
    end
    it "applies a default 'order_by' if none is specified" do
      get :index, params: {}
      expect(session[:filter_device_groups]).to include(order_by: 'name')
    end
    it "applies the 'order_by' parameter" do
      b = FactoryBot.create(:default_device_group, name: 'b')
      a = FactoryBot.create(:default_device_group, name: 'a')
      c = FactoryBot.create(:default_device_group, name: 'c')
      get :index, params: { order_by: 'name desc' }
      expect(assigns(:device_groups)).to eq([c, b, a])
    end
    it "applies the 'with_name' filter" do
      expect(DeviceGroup).to receive(:with_name).with('xxx').and_return(device_groups)
      get :index, params: { with_name: 'xxx' }
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
        it 'returns the first page of device_groups' do
          3.times { |_i| FactoryBot.create(:default_device_group) }
          get :index
          expect(assigns(:device_groups).count).to eq(2)
        end
      end
      context 'with an explicit page value' do
        it 'returns the requested page of device_groups' do
          3.times { |_i| FactoryBot.create(:default_device_group) }
          get :index, params: { page: 2 }
          expect(assigns(:device_groups).count).to eq(1)
        end
      end
    end
  end

  describe 'GET #clear_filter' do
    it 'redirects to #index' do
      get :clear_filter
      expect(response).to redirect_to(device_groups_path)
    end
    it 'clears the session entry' do
      session[:filter_device_groups] = { 'with_name' => 'xxx' }
      get :clear_filter
      expect(session.key?(:filter_device_groups)).to be false
    end
  end

  describe 'GET #show' do
    let(:device_group) { FactoryBot.create(:default_device_group) }
    it 'shows a record' do
      get(:show, params: { id: device_group.id })
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:device_group).id).to eq(device_group.id)
      expect(assigns(:title)).to eq('Device group details')
    end
    it 'raises an exception for a missing record' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:show, params: { id: 99 })
      end
    end
  end

  describe 'GET #new' do
    it 'renders a blank form' do
      get :new
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:device_group).id).to be_nil
      expect(assigns(:title)).to eq('New device group')
      expect(assigns(:cancel_path)).to eq(device_groups_path)
    end
  end

  describe 'POST #create' do
    context 'with valid data' do
      let(:device_group) { DeviceGroup.order(:id).last }
      def post_create
        attrs = {
          name: 'xxx',
          notes: 'Some notes'
        }
        post(:create, params: { device_group: attrs })
      end
      before(:each) do
        post_create
      end
      it 'creates a new record' do
        expect do
          post(:create, params: { device_group: FactoryBot.attributes_for(:default_device_group) })
        end.to change(DeviceGroup, :count).by(1)
      end
      it 'redirects to the show action' do
        expect(response).to redirect_to(device_group_path(device_group))
      end
      it 'set a flash message' do
        expect(flash[:notice]).to eq('Device group was created successfully')
      end
      it 'stores the name' do
        expect(device_group.name).to eq('xxx')
      end
      it 'stores the notes' do
        expect(device_group.notes).to eq('Some notes')
      end
    end
    context 'with invalid data' do
      def post_create
        attrs = FactoryBot.attributes_for(:device_group, notes: 'xxx')
        post(:create, params: { device_group: attrs })
      end
      it 'does not create a new record' do
        expect do
          post_create
        end.to_not change(DeviceGroup, :count)
      end
      it 're-renders the form with the posted data and title' do
        post_create
        expect(response).to render_template(:edit)
        expect(assigns(:device_group).notes).to eq('xxx')
        expect(assigns(:title)).to eq('New device group')
        expect(assigns(:cancel_path)).to eq(device_groups_path)
      end
    end
  end

  describe 'GET #edit' do
    let(:device_group) { FactoryBot.create(:default_device_group) }
    it 'shows a record for editing' do
      get(:edit, params: { id: device_group.id })
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:device_group).id).to eq(device_group.id)
      expect(assigns(:title)).to eq('Edit device group details')
      expect(assigns(:cancel_path)).to eq(device_group_path(device_group))
    end
    it 'raises an exception for a missing record' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:edit, params: { id: 99 })
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid data' do
      let(:device_group) { FactoryBot.create(:default_device_group, name: 'Original') }
      def post_update
        put(:update,
            params: {
              id: device_group.id,
              device_group: {
                name: 'Changed'
              }
            })
        device_group.reload
      end
      before(:each) do
        post_update
      end
      it 'updates the device_group details' do
        expect(device_group.name).to eq('Changed')
      end
      it 'redirects to the show action' do
        expect(response).to redirect_to(device_group_path(assigns(:device_group)))
      end
      it 'sets a flash message' do
        expect(flash[:notice]).to eq('Device group was updated successfully')
      end
    end
    context 'with invalid data' do
      let(:device_group) { FactoryBot.create(:default_device_group, name: 'Original') }
      def post_update
        put(:update, params: { id: device_group.id, device_group: { name: '' } })
        device_group.reload
      end
      before(:each) do
        post_update
      end
      it 'does not update the device_group details' do
        expect(device_group.name).to eq('Original')
      end
      it 're-renders the form with the posted data' do
        expect(response).to render_template(:edit)
        expect(assigns(:device_group).name).to eq('')
        expect(assigns(:title)).to eq('Edit device group details')
        expect(assigns(:cancel_path)).to eq(device_group_path(device_group))
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:device_group) { FactoryBot.create(:default_device_group) }
    it 'deletes the record' do
      expect do
        delete(:destroy, params: { id: device_group.id })
      end.to change(DeviceGroup, :count).by(-1)
    end
    it 'redirects to #index' do
      delete(:destroy, params: { id: device_group.id })
      expect(response).to redirect_to(device_groups_path)
    end
  end
end
