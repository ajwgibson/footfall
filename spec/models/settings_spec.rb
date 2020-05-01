require 'rails_helper'

RSpec.describe Settings, type: :model do
  it 'has a valid factory' do
    expect(
      FactoryBot.build(:default_settings)
    ).to be_valid
  end

  # VALIDATION
  describe 'A valid record' do
    it 'has a default_footfall_threshold_amber value' do
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber: nil)
      ).not_to be_valid
    end

    it 'has a default_footfall_threshold_amber value between 1 and 65,535' do
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber:     0)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber:     1)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber: 65535)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_amber: 65536)
      ).not_to be_valid
    end

    it 'has a default_footfall_threshold_red value' do
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red: nil)
      ).not_to be_valid
    end

    it 'has a default_footfall_threshold_red value between 1 and 65,535' do
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red:     0)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red:     1)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red: 65535)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_footfall_threshold_red: 65536)
      ).not_to be_valid
    end

    it 'has a default_battery_threshold_amber value' do
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber: nil)
      ).not_to be_valid
    end

    it 'has a default_battery_threshold_amber value between 1 and 99' do
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber:   0)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber:   1)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber:  99)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_amber: 100)
      ).not_to be_valid
    end

    it 'has a default_battery_threshold_red value' do
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red: nil)
      ).not_to be_valid
    end

    it 'has a default_battery_threshold_red value between 1 and 99' do
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red:   0)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red:   1)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red:  99)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_battery_threshold_red: 100)
      ).not_to be_valid
    end

    it 'has a default_latitude value' do
      expect(FactoryBot.build(:default_settings, default_latitude: nil)).not_to be_valid
    end

    it 'has a default_latitude value between -90 and 90' do
      expect(
        FactoryBot.build(:default_settings, default_latitude: -90.000001)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_latitude: -90.000000)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_latitude:  90.000000)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_latitude:  90.000001)
      ).not_to be_valid
    end

    it 'has a default_longitude value' do
      expect(FactoryBot.build(:default_settings, default_longitude: nil)).not_to be_valid
    end

    it 'has a default_longitude value between -180 and 180' do
      expect(
        FactoryBot.build(:default_settings, default_longitude: -180.000001)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_longitude: -180.000000)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_longitude:  180.000000)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_longitude:  180.000001)
      ).not_to be_valid
    end

    it 'has a default_zoom_no_location value' do
      expect(FactoryBot.build(:default_settings, default_zoom_no_location: nil)).not_to be_valid
    end

    it 'has a default_zoom_no_location value between 0 and 18' do
      expect(
        FactoryBot.build(:default_settings, default_zoom_no_location:  -1)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_zoom_no_location:   0)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_zoom_no_location:  18)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_zoom_no_location:  19)
      ).not_to be_valid
    end

    it 'has a default_zoom_specific_location value' do
      expect(FactoryBot.build(:default_settings, default_zoom_specific_location: nil)).not_to be_valid
    end

    it 'has a default_zoom_specific_location value between 0 and 18' do
      expect(
        FactoryBot.build(:default_settings, default_zoom_specific_location:  -1)
      ).not_to be_valid
      expect(
        FactoryBot.build(:default_settings, default_zoom_specific_location:   0)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_zoom_specific_location:  18)
      ).to     be_valid
      expect(
        FactoryBot.build(:default_settings, default_zoom_specific_location:  19)
      ).not_to be_valid
    end
  end

  # METHODS

  describe 'self.current' do
    context 'with at least one database entry' do
      before do
        @a = FactoryBot.create(:default_settings)
        @b = FactoryBot.create(:default_settings)
      end
      it 'returns the most recent settings' do
        expect(Settings.current).to eq(@b)
      end
    end
    context 'with no database entry' do
      it 'returns default settings' do
        expect(Settings.current.id).to be_nil
      end
    end
  end

end
