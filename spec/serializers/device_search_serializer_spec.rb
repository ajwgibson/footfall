require 'rails_helper'

RSpec.describe DeviceSearchSerializer, type: :serializer do

  let(:device) { FactoryBot.create(:default_device) }
  subject(:json) { DeviceSearchSerializer.new(device).serializable_hash }

  it 'returns a subset of a device properties' do
    expect(json.keys.sort).to eq(%i[
      device_id
      id
    ])
  end
end
