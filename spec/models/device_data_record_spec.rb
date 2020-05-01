require 'rails_helper'

RSpec.describe DeviceDataRecord, type: :model do
  it 'has a valid default factory' do
    expect(FactoryBot.build(:default_device_data_record)).to be_valid
  end

  # VALIDATION
  describe 'A valid device data record' do
    it 'has a device id' do
      expect(FactoryBot.build(:default_device_data_record, device_id: nil)).not_to be_valid
    end
  end

  # SCOPES
  describe 'scope:with_device_id' do
    before(:each) do
      @a = FactoryBot.create(:default_device_data_record, device_id: 'x')
      @b = FactoryBot.create(:default_device_data_record, device_id: 'y')
      @c = FactoryBot.create(:default_device_data_record, device_id: 'aXa')
    end
    it 'includes records where the device_id contains the value regardless of case' do
      filtered = DeviceDataRecord.with_device_id('x')
      expect(filtered).to     include(@a, @c)
      expect(filtered).not_to include(@b)
    end
  end

  describe 'scope:recorded_on' do
    before(:each) do
      @a = FactoryBot.create(:default_device_data_record, recorded_at: 2.days.ago)
      @b = FactoryBot.create(:default_device_data_record, recorded_at: 3.days.ago)
    end
    it 'includes records where the recorded_at value matches the date provided' do
      filtered = DeviceDataRecord.recorded_on(2.days.ago.to_date)
      expect(filtered).to eq([@a])
    end
  end
end
