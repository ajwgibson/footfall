require 'rails_helper'

RSpec.describe Device, type: :model do
  describe 'Device' do
    it 'has a valid default factory' do
      expect(FactoryBot.build(:default_device)).to be_valid
    end
  end

  # VALIDATION
  describe 'A valid device' do
    it 'has a device id' do
      expect(FactoryBot.build(:default_device, device_id: nil)).not_to be_valid
    end

    it 'has a unique id' do
      FactoryBot.create(:default_device, device_id: 'xxx')
      expect(FactoryBot.build(:default_device, device_id: 'xxx')).not_to be_valid
    end

    it 'has a footfall_threshold_amber value' do
      expect(FactoryBot.build(:default_device, footfall_threshold_amber: nil)).not_to be_valid
    end

    it 'has a footfall_threshold_amber value between 1 and 65,535' do
      expect(FactoryBot.build(:default_device, footfall_threshold_amber:     0)).not_to be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_amber:     1)).to     be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_amber: 65535)).to     be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_amber: 65536)).not_to be_valid
    end

    it 'has a footfall_threshold_red value' do
      expect(FactoryBot.build(:default_device, footfall_threshold_red: nil)).not_to be_valid
    end

    it 'has a footfall_threshold_red value between 1 and 65,535' do
      expect(FactoryBot.build(:default_device, footfall_threshold_red:     0)).not_to be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_red:     1)).to     be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_red: 65535)).to     be_valid
      expect(FactoryBot.build(:default_device, footfall_threshold_red: 65536)).not_to be_valid
    end

    it 'has a battery_threshold_amber value' do
      expect(FactoryBot.build(:default_device, battery_threshold_amber: nil)).not_to be_valid
    end

    it 'has a battery_threshold_amber value between 1 and 99' do
      expect(FactoryBot.build(:default_device, battery_threshold_amber:   0)).not_to be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_amber:   1)).to     be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_amber:  99)).to     be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_amber: 100)).not_to be_valid
    end

    it 'has a battery_threshold_red value' do
      expect(FactoryBot.build(:default_device, battery_threshold_red: nil)).not_to be_valid
    end

    it 'has a battery_threshold_red value between 1 and 99' do
      expect(FactoryBot.build(:default_device, battery_threshold_red:   0)).not_to be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_red:   1)).to     be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_red:  99)).to     be_valid
      expect(FactoryBot.build(:default_device, battery_threshold_red: 100)).not_to be_valid
    end
  end

  # CALLBACKS
  describe '#before_save' do
    it 'swaps the battery_threshold_red and battery_threshold_amber values if necessary' do
      device = FactoryBot.create(
        :default_device,
        battery_threshold_red: 2,
        battery_threshold_amber: 1
      )
      device.reload
      expect(device.battery_threshold_red).to eq(1)
      expect(device.battery_threshold_amber).to eq(2)
    end

    it 'swaps the footfall_threshold_red and footfall_threshold_amber values if necessary' do
      device = FactoryBot.create(
        :default_device,
        footfall_threshold_red: 1,
        footfall_threshold_amber: 2
      )
      device.reload
      expect(device.footfall_threshold_red).to eq(2)
      expect(device.footfall_threshold_amber).to eq(1)
    end
  end

  # SCOPES
  describe 'scope:ordered_by_device_id' do
    before(:each) do
      @c = FactoryBot.create(:default_device, device_id: 'c')
      @a = FactoryBot.create(:default_device, device_id: 'a')
      @b = FactoryBot.create(:default_device, device_id: 'b')
    end
    it 'orders the records by device_id' do
      expect(Device.ordered_by_device_id).to eq([@a, @b, @c])
    end
  end

  describe 'scope:with_device_id' do
    before(:each) do
      @a = FactoryBot.create(:default_device, device_id: 'x')
      @b = FactoryBot.create(:default_device, device_id: 'y')
      @c = FactoryBot.create(:default_device, device_id: 'aXa')
    end
    it 'includes records where the device id contains the value regardless of case' do
      filtered = Device.with_device_id('x')
      expect(filtered).to     include(@a, @c)
      expect(filtered).not_to include(@b)
    end
  end

  describe 'scope:with_device_group_id' do
    let(:device_group) { FactoryBot.create(:default_device_group) }
    before(:each) do
      @a = FactoryBot.create(:default_device, device_group: nil)
      @b = FactoryBot.create(:default_device, device_group: device_group)
    end
    it 'includes records where the device belongs to the group' do
      filtered = Device.with_device_group_id(device_group.id)
      expect(filtered).to     include(@b)
      expect(filtered).not_to include(@a)
    end
  end

  describe 'self.with_battery_status' do
    context 'when the parameter passed is green' do
      before(:each) do
        @a = FactoryBot.create(:default_device, battery: 91, battery_threshold_amber: 90)
        @b = FactoryBot.create(:default_device, battery: 90, battery_threshold_amber: 90)
      end
      it 'returns devices with battery more than the amber threshold' do
        results = Device.with_battery_status('green')
        expect(results).to eq([@a])
      end
    end
    context 'when the parameter passed is amber' do
      before(:each) do
        @a = FactoryBot.create(:default_device, battery: 91, battery_threshold_amber: 90)
        @b = FactoryBot.create(:default_device, battery: 90, battery_threshold_amber: 90)
        @c = FactoryBot.create(
          :default_device,
          battery: 89,
          battery_threshold_amber: 90,
          battery_threshold_red: 89
        )
      end
      it 'returns devices with battery > the red threshold and <= the amber threshold' do
        results = Device.with_battery_status('amber')
        expect(results).to eq([@b])
      end
    end
    context 'when the parameter passed is red' do
      before(:each) do
        @a = FactoryBot.create(:default_device, battery: 90, battery_threshold_amber: 90)
        @b = FactoryBot.create(
          :default_device,
          battery: 89,
          battery_threshold_amber: 90,
          battery_threshold_red: 89
        )
      end
      it 'returns devices with battery <= the red threshold' do
        results = Device.with_battery_status('red')
        expect(results).to eq([@b])
      end
    end
  end

  describe 'self.with_footfall_status' do
    context 'when the parameter passed is green' do
      before(:each) do
        @a = FactoryBot.create(:default_device, footfall:  1, footfall_threshold_amber: 10)
        @b = FactoryBot.create(:default_device, footfall: 10, footfall_threshold_amber: 10)
      end
      it 'returns devices with footfall less than the amber threshold' do
        results = Device.with_footfall_status('green')
        expect(results).to eq([@a])
      end
    end
    context 'when the parameter passed is amber' do
      before(:each) do
        @a = FactoryBot.create(:default_device, footfall:  1, footfall_threshold_amber: 10)
        @b = FactoryBot.create(:default_device, footfall: 10, footfall_threshold_amber: 10)
        @c = FactoryBot.create(
          :default_device,
          footfall: 11,
          footfall_threshold_amber: 10,
          footfall_threshold_red: 11
        )
      end
      it 'returns devices with footfall < the red threshold and >= the amber threshold' do
        results = Device.with_footfall_status('amber')
        expect(results).to eq([@b])
      end
    end
    context 'when the parameter passed is red' do
      before(:each) do
        @a = FactoryBot.create(:default_device, footfall: 10, footfall_threshold_amber: 10)
        @b = FactoryBot.create(
          :default_device,
          footfall: 11,
          footfall_threshold_amber: 10,
          footfall_threshold_red: 11
        )
      end
      it 'returns devices with footfall >= the red threshold' do
        results = Device.with_footfall_status('red')
        expect(results).to eq([@b])
      end
    end
  end

  describe 'self.with_a_location' do
    before(:each) do
      @a = FactoryBot.create(:default_device, latitude: 1, longitude: 2)
      @b = FactoryBot.create(:default_device, latitude: nil, longitude: 2)
      @c = FactoryBot.create(:default_device, latitude: 1, longitude: nil)
      @d = FactoryBot.create(:default_device, latitude: nil, longitude: nil)
    end
    context 'when called with a value of true' do
      it 'includes records where the latitude and longitude are both set' do
        filtered = Device.with_a_location('true')
        expect(filtered).to     eq([@a])
      end
    end
    context 'when called with a value of false' do
      it 'includes records where the latitude and/or longitude is not set' do
        filtered = Device.with_a_location('false')
        expect(filtered).not_to include(@a)
        expect(filtered).to include(@b, @c, @d)
      end
    end
  end

  # METHODS
  describe 'self.new_device' do
    before(:each) do
      FactoryBot.create(:default_settings)
    end
    it 'initializes a device using system settings for defaults' do
      device = Device.new_device
      settings = Settings.current
      expect(device.battery_threshold_red).to eq(settings.default_battery_threshold_red)
      expect(device.battery_threshold_amber).to eq(settings.default_battery_threshold_amber)
      expect(device.footfall_threshold_red).to eq(settings.default_footfall_threshold_red)
      expect(device.footfall_threshold_amber).to eq(settings.default_footfall_threshold_amber)
    end
  end

  describe '#footfall_red?' do
    let(:device) {
      FactoryBot.build(
        :default_device,
        footfall_threshold_amber: 10,
        footfall_threshold_red: 20
      )
    }
    context 'when footfall value is nil' do
      it 'is false' do
        device.footfall = nil
        expect(device.footfall_red?).to be_falsey
      end
    end
    context 'when footfall count < red threshold' do
      it 'is false' do
        device.footfall = device.footfall_threshold_red - 1
        expect(device.footfall_red?).to be_falsey
      end
    end
    context 'when footfall count >= red threshold' do
      it 'is true' do
        device.footfall = device.footfall_threshold_red
        expect(device.footfall_red?).to be_truthy
      end
    end
  end

  describe '#footfall_amber?' do
    let(:device) {
      FactoryBot.build(
        :default_device,
        footfall_threshold_amber: 10,
        footfall_threshold_red: 20
      )
    }
    context 'when footfall value is nil' do
      it 'is false' do
        device.footfall = nil
        expect(device.footfall_amber?).to be_falsey
      end
    end
    context 'when footfall count < amber threshold' do
      it 'is false' do
        device.footfall = device.footfall_threshold_amber - 1
        expect(device.footfall_amber?).to be_falsey
      end
    end
    context 'when footfall count >= amber threshold' do
      it 'is true' do
        device.footfall = device.footfall_threshold_amber
        expect(device.footfall_amber?).to be_truthy

        device.footfall = device.footfall_threshold_amber + 1
        expect(device.footfall_amber?).to be_truthy
      end
    end
    context 'when footfall count >= red threshold' do
      it 'is false' do
        device.footfall = device.footfall_threshold_red
        expect(device.footfall_amber?).to be_falsey
      end
    end
  end

  describe '#footfall_green?' do
    let(:device) {
      FactoryBot.build(
        :default_device,
        footfall_threshold_amber: 10,
        footfall_threshold_red: 20
      )
    }
    context 'when footfall value is nil' do
      it 'is false' do
        device.footfall = nil
        expect(device.footfall_green?).to be_falsey
      end
    end
    context 'when footfall count < amber threshold' do
      it 'is true' do
        device.footfall = device.footfall_threshold_amber - 1
        expect(device.footfall_green?).to be_truthy
      end
    end
    context 'when footfall count >= amber threshold' do
      it 'is false' do
        device.footfall = device.footfall_threshold_amber
        expect(device.footfall_green?).to be_falsey
      end
    end
  end

  describe '#battery_red?' do
    let(:device) {
      FactoryBot.build(
        :default_device,
        battery_threshold_amber: 10,
        battery_threshold_red: 20
      )
    }
    context 'when battery value is nil' do
      it 'is false' do
        device.battery = nil
        expect(device.battery_red?).to be_falsey
      end
    end
    context 'when battery value <= red threshold' do
      it 'is true' do
        device.battery = device.battery_threshold_red
        expect(device.battery_red?).to be_truthy
      end
    end
    context 'when battery value > red threshold' do
      it 'is false' do
        device.battery = device.battery_threshold_red + 1
        expect(device.battery_red?).to be_falsey
      end
    end
  end

  describe '#battery_amber?' do
    let(:device) {
      FactoryBot.build(
        :default_device,
        battery_threshold_amber: 20,
        battery_threshold_red: 10
      )
    }
    context 'when battery value is nil' do
      it 'is false' do
        device.battery = nil
        expect(device.battery_amber?).to be_falsey
      end
    end
    context 'when battery value <= red threshold' do
      it 'is false' do
        device.battery = device.battery_threshold_red
        expect(device.battery_amber?).to be_falsey
      end
    end
    context 'when battery value <= amber threshold' do
      it 'is true' do
        device.battery = device.battery_threshold_amber
        expect(device.battery_amber?).to be_truthy

        device.battery = device.battery_threshold_amber - 1
        expect(device.battery_amber?).to be_truthy
      end
    end
    context 'when battery value > amber threshold' do
      it 'is false' do
        device.battery = device.battery_threshold_amber + 1
        expect(device.battery_amber?).to be_falsey
      end
    end
  end

  describe '#battery_green?' do
    let(:device) {
      FactoryBot.build(
        :default_device,
        battery_threshold_amber: 10,
        battery_threshold_red: 20
      )
    }
    context 'when battery value is nil' do
      it 'is false' do
        device.battery = nil
        expect(device.battery_green?).to be_falsey
      end
    end
    context 'when battery value > amber threshold' do
      it 'is true' do
        device.battery = device.battery_threshold_amber + 1
        expect(device.battery_green?).to be_truthy
      end
    end
    context 'when battery value <= amber threshold' do
      it 'is false' do
        device.battery = device.battery_threshold_amber
        expect(device.battery_green?).to be_falsey
      end
    end
  end

  describe '#colour' do
    it 'has not been tested yet Alan!!!'
  end

  describe '#location_as_string' do
    it 'returns latitude and longitude' do
      device = FactoryBot.build(:default_device, latitude: 1.23, longitude: -9.87)
      expect(device.location_as_string).to eq('1.23, -9.87')
    end
    it 'returns nil if latitude is nil' do
      device = FactoryBot.build(:default_device, latitude: nil, longitude: -9.87)
      expect(device.location_as_string).to be_nil
    end
    it 'returns nil if longitude is nil' do
      device = FactoryBot.build(:default_device, latitude: 1.23, longitude: nil)
      expect(device.location_as_string).to be_nil
    end
  end

  describe '#raise_footfall_alarm' do
    it 'has not been tested yet Alan!!!'
  end

  describe '#raise_battery_alarm' do
    it 'has not been tested yet Alan!!!'
  end
end
