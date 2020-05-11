require 'rails_helper'

RSpec.describe Api::DevicesController, type: :controller do
  login_user

  describe 'GET #index' do
    let!(:device_b) { FactoryBot.create(:default_device, device_id: 'bX') }
    let!(:device_a) { FactoryBot.create(:default_device, device_id: 'aX') }
    let(:results) { JSON.parse(response.body) }
    context 'with no search parameter' do
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
      it 'returns all devices' do
        get :index
        expect(results.size).to eq(2)
      end
      it 'orders the results by device_id' do
        get :index
        expect(results.map { |d| d['id'] }).to eq([device_a.id, device_b.id])
      end
    end
    context 'with a search parameter' do
      it 'filters the results' do
        get :index, params: { device_id: 'b' }
        expect(results.size).to eq(1)
        expect(results[0]['device_id']).to eq('bX')
      end
    end
  end
end
