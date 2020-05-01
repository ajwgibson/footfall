FactoryBot.define do
  factory :device_data_record do
  end

  factory :default_device_data_record, parent: :device_data_record do
    device_id   { "#{('A'..'Z').to_a.sample}-#{(Time.now.to_f * 1000).to_i}" }
    footfall    { 50 }
    battery     { 63 }
    recorded_at { 12.minutes.ago }
  end
end
