FactoryBot.define do
  factory :device do
  end

  factory :default_device, parent: :device do
    device_id { "#{('A'..'Z').to_a.sample}-#{(Time.now.to_f * 1000).to_i}" }

    footfall_threshold_amber  {  50 }
    footfall_threshold_red    { 100 }

    battery_threshold_amber   {  50 }
    battery_threshold_red     {  30 }

    footfall { rand(0..200) }
    battery  { rand(0..100) }

    device_type { [:emulated, :arduino].sample }
  end
end
