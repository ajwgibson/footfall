# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Audit, type: :model do
  context '#humanize' do
    it 'returns a human friendly version of a type name' do
      expect(Audit.humanize('User')).to eq('User')
      expect(Audit.humanize('FootfallCounter')).to eq('Footfall counter')
    end
  end

  context '#humanized_item_type' do
    it 'returns a human friendly version of a type name' do
      expect(
        FactoryBot.build(
          :default_audit,
          item_type: 'Client'
        ).humanized_item_type
      ).to eq('Client')
      expect(
        FactoryBot.build(
          :default_audit,
          item_type: 'FootfallCounter'
        ).humanized_item_type
      ).to eq('Footfall counter')
    end
  end

  context '#selectable_item_types' do
    before(:each) do
      FactoryBot.create(:default_audit, item_type: 'AaA')
      FactoryBot.create(:default_audit, item_type: 'AaA')
      FactoryBot.create(:default_audit, item_type: 'BaA')
      FactoryBot.create(:default_audit, item_type: 'AaB')
    end
    it 'returns a list of distinct entries' do
      expect(Audit.selectable_item_types).to eq(%w[AaA AaB BaA])
    end
  end
end
