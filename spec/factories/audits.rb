# frozen_string_literal: true

FactoryBot.define do
  factory :audit do
  end

  factory :default_audit, parent: :audit do
    item_type          { 'AnItemType' }
    item_id            { rand(1..10) }
    event              { %w[create update destroy].sample }
    whodunnit          { Faker::Name.name }
  end
end
