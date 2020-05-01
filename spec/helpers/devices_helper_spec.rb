# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesHelper, type: :helper do

  describe 'device_battery_status' do
    let(:device) {
      FactoryBot.build(
        :default_device,
        battery_threshold_amber: 50,
        battery_threshold_red: 10,
        battery: 75
      )
    }
    let(:result) { device_battery_status(device) }
    it 'includes the battery value as a percentage' do
      expect(result).to include('75%')
    end
    it 'returns an empty string if the device battery value is not set' do
      device.battery = nil
      expect(result).to be_empty
    end
    context 'when the battery status is more than the amber threshold' do
      before(:each) { device.battery = 90 }
      it 'uses green text' do
        expect(result).to include('text-green')
      end
      it 'uses a full battery icon' do
        expect(result).to include('battery-full')
      end
    end
    context 'when the battery status is less than the amber threshold' do
      before(:each) { device.battery = 40 }
      it 'uses amber text' do
        expect(result).to include('text-warning')
      end
      it 'uses a half full battery icon' do
        expect(result).to include('battery-half')
      end
    end
    context 'when the battery status is less than the red threshold' do
      before(:each) { device.battery = 5 }
      it 'uses red text' do
        expect(result).to include('text-danger')
      end
      it 'uses a empty battery icon' do
        expect(result).to include('battery-empty')
      end
    end
  end

  describe 'device_footfall_status' do
    let(:device) {
      FactoryBot.build(
        :default_device,
        footfall_threshold_amber: 50,
        footfall_threshold_red: 100,
        footfall: 25
      )
    }
    let(:result) { device_footfall_status(device) }
    it 'includes the footfall count' do
      expect(result).to include('25')
    end
    it 'includes a nice icon' do
      expect(result).to include('shoe-prints')
    end
    it 'returns an empty string if the footfall value is not set' do
      device.footfall = nil
      expect(result).to be_empty
    end
    context 'when the footfall is less than the amber threshold' do
      before(:each) { device.footfall = 40 }
      it 'uses green text' do
        expect(result).to include('text-green')
      end
    end
    context 'when the footfall is more than the amber threshold' do
      before(:each) { device.footfall = 60 }
      it 'uses amber text' do
        expect(result).to include('text-warning')
      end
    end
    context 'when the footfall is more than the red threshold' do
      before(:each) { device.footfall = 105 }
      it 'uses red text' do
        expect(result).to include('text-danger')
      end
    end
  end

  describe 'device_map_icon_url' do
    it 'has not been tested yet Alan!!!'
  end
end