require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { Ability.new(user) }

  context "an administrator" do
    let(:user) { FactoryBot.build(:administrator) }
    it { is_expected.to have_abilities([:manage], :all) }
  end

  context "a standard user" do
    let(:user) { FactoryBot.build(:default_user) }
    it { is_expected.not_to have_abilities([:manage], :all) }

    it { is_expected.to have_abilities([:manage], Alarm) }
    it { is_expected.to have_abilities([:manage], Device) }
    it { is_expected.to have_abilities([:manage], DeviceGroup) }
    it { is_expected.to have_abilities([:manage], DeviceDataRecord) }
  end
end
