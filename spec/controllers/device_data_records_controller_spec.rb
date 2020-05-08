# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeviceDataRecordsController, type: :controller do
  login_user

  describe 'GET #index' do
    let(:records) { double('records') }
    before(:each) do
      allow(records).to receive(:order_by).and_return(records)
      allow(records).to receive(:order).and_return(records)
      allow(records).to receive(:page).and_return(records)
    end
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
    it 'populates an array of records' do
      record = FactoryBot.create(:default_device_data_record)
      get :index
      expect(assigns(:device_data_records)).to include(record)
    end
    it 'stores filters to the session' do
      get :index, params: { with_device_id: 'xxx' }
      expect(session[:filter_device_data_records].except(:order_by)).to eq('with_device_id' => 'xxx')
    end
    it 'removes blank filter values' do
      get :index, params: { with_device_id: nil }
      expect(assigns(:filter).except(:order_by)).to eq({})
    end
    it 'retrieves filters from the session if none have been supplied' do
      a = FactoryBot.create(:default_device_data_record, device_id: 'xxx')
      FactoryBot.create(:default_device_data_record, device_id: 'yyy')
      get :index, params: {}, session: { filter_device_data_records: { with_device_id: 'xxx' } }
      expect(assigns(:device_data_records)).to eq([a])
    end
    it "applies a default 'order_by' if none is specified" do
      get :index, params: {}
      expect(session[:filter_device_data_records]).to include(order_by: 'recorded_at desc')
    end
    it "applies the 'order_by' parameter" do
      b = FactoryBot.create(:default_device_data_record, device_id: 'b')
      a = FactoryBot.create(:default_device_data_record, device_id: 'a')
      c = FactoryBot.create(:default_device_data_record, device_id: 'c')
      get :index, params: { order_by: 'device_id desc' }
      expect(assigns(:device_data_records)).to eq([c, b, a])
    end
    it "applies the 'with_device_id' filter" do
      expect(DeviceDataRecord).to receive(:with_device_id).with('xxx').and_return(records)
      get :index, params: { with_device_id: 'xxx' }
    end
    it "applies the 'recorded_on' filter" do
      expect(DeviceDataRecord).to(
        receive(:recorded_on).with('2017-12-13'.to_date).and_return(records)
      )
      get :index, params: { recorded_on: '13/12/2017' }
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
        it 'returns the first page of records' do
          3.times { |_i| FactoryBot.create(:default_device_data_record) }
          get :index
          expect(assigns(:device_data_records).count).to eq(2)
        end
      end
      context 'with an explicit page value' do
        it 'returns the requested page of records' do
          3.times { |_i| FactoryBot.create(:default_device_data_record) }
          get :index, params: { page: 2 }
          expect(assigns(:device_data_records).count).to eq(1)
        end
      end
    end
  end

  describe 'GET #clear_filter' do
    it 'redirects to #index' do
      get :clear_filter
      expect(response).to redirect_to(device_data_records_path)
    end
    it 'clears the session entry' do
      session[:filter_device_data_records] = { 'with_device_id' => 'xxx' }
      get :clear_filter
      expect(session.key?(:filter_device_data_records)).to be false
    end
  end

  describe 'DELETE #destroy' do
    let!(:record) { FactoryBot.create(:default_device_data_record) }
    it 'deletes the record' do
      expect do
        delete(:destroy, params: { id: record.id })
      end.to change(DeviceDataRecord, :count).by(-1)
    end
    it 'redirects to #index' do
      delete(:destroy, params: { id: record.id })
      expect(response).to redirect_to(device_data_records_path)
    end
  end
end
