# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SettingsController, type: :controller do
  login_user

  describe 'GET #show' do
    let!(:settings) { FactoryBot.create(:default_settings) }
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end
    it 'renders the :show view' do
      get :show
      expect(response).to render_template :show
    end
    it 'sets the page title' do
      get :show
      expect(assigns(:title)).to eq('System settings')
    end
    it 'shows the current settings' do
      expect(Settings).to receive(:current).and_return(settings)
      get :show
      expect(assigns(:settings).id).to eq(settings.id)
    end
  end

  describe 'GET #edit' do
    let!(:settings) { FactoryBot.create(:default_settings) }
    it 'shows a copy of the current settings record for editing' do
      get :edit
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:settings).id).to eq(settings.id)
      expect(assigns(:title)).to eq('Edit system settings')
    end
  end

  describe 'POST #update' do
    let(:settings) { Settings.current }
    context 'when there is no existing database record' do
      before(:each) do
        post :update, params: { settings: attrs }
      end
      context 'with valid data' do
        let(:attrs) { FactoryBot.attributes_for(:default_settings) }
        it 'creates a new record' do
          expect(Settings.count).to eq(1)
        end
        it 'redirects to the show action' do
          expect(response).to redirect_to(settings_path)
        end
        it 'set a flash message' do
          expect(flash[:notice]).to eq('System settings updated successfully')
        end
        it 'stores the form data' do
          expect(settings.default_footfall_threshold_amber).to(
            eq(attrs[:default_footfall_threshold_amber])
          )
          expect(settings.default_footfall_threshold_red).to(
            eq(attrs[:default_footfall_threshold_red])
          )
          expect(settings.default_battery_threshold_amber).to(
            eq(attrs[:default_battery_threshold_amber])
          )
          expect(settings.default_battery_threshold_red).to(
            eq(attrs[:default_battery_threshold_red])
          )
          expect(settings.default_latitude).to(
            eq(attrs[:default_latitude])
          )
          expect(settings.default_longitude).to(
            eq(attrs[:default_longitude])
          )
          expect(settings.default_zoom_no_location).to(
            eq(attrs[:default_zoom_no_location])
          )
          expect(settings.default_zoom_specific_location).to(
            eq(attrs[:default_zoom_specific_location])
          )
        end
      end
      context 'with invalid data' do
        let(:attrs) { FactoryBot.attributes_for(:settings, default_battery_threshold_red: 999) }
        it 're-renders the form with the posted data' do
          expect(response).to render_template(:edit)
          expect(assigns(:title)).to eq('Edit system settings')
          expect(assigns(:settings).default_battery_threshold_red).to eq(999)
        end
      end
    end
    context 'when there is already a database record' do
      let(:attrs) {
        FactoryBot.attributes_for(:default_settings, default_battery_threshold_red: 98)
      }
      before(:each) do
        FactoryBot.create(:default_settings, default_battery_threshold_red: 99)
        post :update, params: { settings: attrs }
      end
      it 'does not create a new record' do
        expect(Settings.count).to eq(1)
      end
      it 'updates the record' do
        expect(settings.default_battery_threshold_red).to eq(98)
      end
    end
  end
end
