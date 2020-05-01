# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlarmsController, type: :controller do
  login_user

  describe 'GET #index' do
    let(:alarms) { double('alarms') }
    before(:each) do
      allow(alarms).to receive(:order_by).and_return(alarms)
      allow(alarms).to receive(:order).and_return(alarms)
      allow(alarms).to receive(:page).and_return(alarms)
    end
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'renders the :index view' do
      get :index
      expect(response).to render_template :index
    end
    it 'populates an array of alarms' do
      alarm = FactoryBot.create(:default_alarm)
      get :index
      expect(assigns(:alarms)).to include(alarm)
    end
    it 'stores filters to the session' do
      get :index, params: { with_device_id: 'xxx' }
      expect(session[:filter_alarms].except(:order_by)).to eq('with_device_id' => 'xxx')
    end
    it 'removes blank filter values' do
      get :index, params: { with_device_id: nil }
      expect(assigns(:filter).except(:order_by)).to eq({})
    end
    it 'retrieves filters from the session if none have been supplied' do
      a = FactoryBot.create(:default_alarm, status: :active)
      FactoryBot.create(:default_alarm, status: :cleared)
      get :index, params: {}, session: { filter_alarms: { with_status: :active } }
      expect(assigns(:alarms)).to eq([a])
    end
    it "applies a default 'order_by' if none is specified" do
      get :index, params: {}
      expect(session[:filter_alarms]).to include(order_by: 'alarms.created_at desc')
    end
    it "applies the 'order_by' parameter" do
      b = FactoryBot.create(:default_alarm, status: :cleared)
      a = FactoryBot.create(:default_alarm, status: :active)
      get :index, params: { order_by: 'status' }
      expect(assigns(:alarms)).to eq([a, b])
    end
    it "applies the 'with_device_id' filter" do
      expect(Alarm).to receive(:with_device_id).with('xxx').and_return(alarms)
      get :index, params: { with_device_id: 'xxx' }
    end
    it "applies the 'with_status' filter" do
      expect(Alarm).to receive(:with_status).with('active').and_return(alarms)
      get :index, params: { with_status: :active }
    end
    it "applies the 'with_alarm_type' filter" do
      expect(Alarm).to receive(:with_alarm_type).with('battery').and_return(alarms)
      get :index, params: { with_alarm_type: :battery }
    end
    it "applies the 'with_level' filter" do
      expect(Alarm).to receive(:with_level).with('red').and_return(alarms)
      get :index, params: { with_level: :red }
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
        it 'returns the first page of alarms' do
          3.times { |_i| FactoryBot.create(:default_alarm) }
          get :index
          expect(assigns(:alarms).count).to eq(2)
        end
      end
      context 'with an explicit page value' do
        it 'returns the requested page of alarms' do
          3.times { |_i| FactoryBot.create(:default_alarm) }
          get :index, params: { page: 2 }
          expect(assigns(:alarms).count).to eq(1)
        end
      end
    end
  end

  describe 'GET #clear_filter' do
    it 'redirects to #index' do
      get :clear_filter
      expect(response).to redirect_to(alarms_path)
    end
    it 'clears the session entry' do
      session[:filter_alarms] = { 'with_device_id' => 'xxx' }
      get :clear_filter
      expect(session.key?(:filter_alarms)).to be false
    end
  end

  describe 'GET #show' do
    let(:alarm) { FactoryBot.create(:default_alarm) }
    it 'shows a record' do
      get(:show, params: { id: alarm.id })
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:alarm).id).to eq(alarm.id)
      expect(assigns(:title)).to eq('Alarm details')
    end
    it 'raises an exception for a missing record' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:show, params: { id: 99 })
      end
    end
  end

  describe 'PUT #clear' do
    let(:alarm) { FactoryBot.create(:default_alarm, status: :active) }
    it 'clears an alarm and displays the show view' do
      put(:clear, params: { id: alarm.id })
      expect(response).to redirect_to(alarm_path(alarm))
      alarm.reload
      expect(alarm.cleared?).to be_truthy
      expect(flash[:notice]).to eq('Alarm was cleared')
    end
    it 'raises an exception for a missing record' do
      assert_raises(ActiveRecord::RecordNotFound) do
        put(:clear, params: { id: 99 })
      end
    end
  end
end
