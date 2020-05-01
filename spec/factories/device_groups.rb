FactoryBot.define do
  factory :device_group do
  end

  factory :default_device_group, parent: :device_group do
    name { "#{('A'..'Z').to_a.sample}-#{(Time.now.to_f * 1000).to_i}" }
  end
end
