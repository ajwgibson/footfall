require 'rails_helper'

RSpec.describe DeviceGroup, type: :model do
  describe 'DeviceGroup' do
    it 'has a valid default factory' do
      expect(FactoryBot.build(:default_device_group)).to be_valid
    end
  end

  # VALIDATION
  describe 'A valid device group' do
    it 'has a name' do
      expect(FactoryBot.build(:default_device_group, name: nil)).not_to be_valid
    end

    it 'has a unique name' do
      FactoryBot.create(:default_device_group, name: 'xxx')
      expect(FactoryBot.build(:default_device_group, name: 'xxx')).not_to be_valid
    end
  end

  # SCOPES
  describe 'scope:with_name' do
    before(:each) do
      @a = FactoryBot.create(:default_device_group, name: 'x')
      @b = FactoryBot.create(:default_device_group, name: 'y')
      @c = FactoryBot.create(:default_device_group, name: 'aXa')
    end
    it 'includes records where the name contains the value regardless of case' do
      filtered = DeviceGroup.with_name('x')
      expect(filtered).to     include(@a, @c)
      expect(filtered).not_to include(@b)
    end
  end

  describe 'scope:ordered_by_name' do
    before(:each) do
      @c = FactoryBot.create(:default_device_group, name: 'c')
      @a = FactoryBot.create(:default_device_group, name: 'a')
      @b = FactoryBot.create(:default_device_group, name: 'b')
    end
    it 'orders the records by name' do
      expect(DeviceGroup.ordered_by_name).to eq([@a, @b, @c])
    end
  end

  # METHODS
  describe '#device_count' do
    let(:device_group) { FactoryBot.create(:default_device_group) }
    it 'returns the number of devices in the group' do
      3.times { device_group.devices << FactoryBot.create(:default_device) }
      expect(device_group.device_count).to eq(3)
    end
  end
end
