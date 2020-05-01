FactoryBot.define do
  factory :alarm do
  end

  factory :default_alarm, parent: :alarm do
    alarm_type { [:footfall, :battery].sample }
    status     { [:active, :cleared].sample }
    level      { [:amber, :red].sample }
    value      { rand(50..100) }
    threshold  { rand(40..50) }

    association :device, factory: :default_device
  end
end
