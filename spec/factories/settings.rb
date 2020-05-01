FactoryBot.define do
  factory :settings do
  end

  factory :default_settings, parent: :settings do
    default_footfall_threshold_amber  {  50 }
    default_footfall_threshold_red    { 100 }
    default_battery_threshold_amber   {  50 }
    default_battery_threshold_red     {  30 }
    default_latitude                  {  55.013479 }
    default_longitude                 {  -6.469507 }
    default_zoom_no_location          {   7 }
    default_zoom_specific_location    {  11 }
  end
end
