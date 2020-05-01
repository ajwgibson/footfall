require 'rails_helper'

RSpec.describe Alarm, type: :model do
  it 'has a valid default factory' do
    expect(FactoryBot.build(:default_alarm)).to be_valid
  end

  # VALIDATION
  describe 'A valid alarm' do
    it 'is linked to a device' do
      expect(FactoryBot.build(:default_alarm, device: nil)).not_to be_valid
    end
    it 'has a value' do
      expect(FactoryBot.build(:default_alarm, value: nil)).not_to be_valid
    end
    it 'has a threshold' do
      expect(FactoryBot.build(:default_alarm, threshold: nil)).not_to be_valid
    end
  end

  # SCOPES
  describe 'scope:with_device_id' do
    let(:device) { FactoryBot.create(:default_device, device_id: 'aXa') }
    before(:each) do
      @a = FactoryBot.create(:default_alarm, device: device)
      @b = FactoryBot.create(:default_alarm)
    end
    it 'includes records where linked device has device id containing value (regardless of case)' do
      filtered = Alarm.with_device_id('x')
      expect(filtered).to eq([@a])
    end
  end

  describe 'scope:with_alarm_type' do
    before(:each) do
      @a = FactoryBot.create(:default_alarm, alarm_type: :footfall)
      @b = FactoryBot.create(:default_alarm, alarm_type: :battery)
    end
    it 'includes records with the matching alarm type' do
      filtered = Alarm.with_alarm_type(:footfall)
      expect(filtered).to eq([@a])
    end
  end

  describe 'scope:with_status' do
    before(:each) do
      @a = FactoryBot.create(:default_alarm, status: :active)
      @b = FactoryBot.create(:default_alarm, status: :cleared)
    end
    it 'includes records with the matching status' do
      filtered = Alarm.with_status(:active)
      expect(filtered).to eq([@a])
    end
  end

  describe 'scope:with_level' do
    before(:each) do
      @a = FactoryBot.create(:default_alarm, level: :red)
      @b = FactoryBot.create(:default_alarm, level: :amber)
    end
    it 'includes records with the matching level' do
      filtered = Alarm.with_level(:red)
      expect(filtered).to eq([@a])
    end
  end
end
