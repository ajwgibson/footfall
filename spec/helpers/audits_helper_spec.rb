# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditsHelper, type: :helper do
  describe '#audits_path_for(item)' do
    it 'returns a path with filter parameters' do
      user = FactoryBot.build(:default_user, id: 3)
      expect(helper.audits_path_for(user)).to eq(
        audits_path(for_item_type: 'User', for_item_id: 3)
      )
    end
  end
end
