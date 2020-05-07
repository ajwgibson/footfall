require 'aws-sdk-dynamodb'

namespace :emulator do
  task :generate_footfall_data, [] => :environment do |task, args|
    puts 'Generating footfall data...'

    Device.left_outer_joins(:device_group)
          .order('device_groups.name, devices.device_id').each do |device|

      battery = generate_battery_level(device)
      footfall = generate_footfall_count(device)

      puts <<~EOF.squish
        Device group: #{device&.device_group&.name},
        Device ID: #{device.device_id},
        Footfall: #{footfall},
        Battery: #{battery}
      EOF

      unless battery.nil?
        write_footfall_data_to_aws({
          dev_id: device.device_id,
          time: Time.now.strftime('%FT%T'),
          footfall: footfall,
          battery: battery,
        })
      end

      sleep rand(10)
    end

    puts 'Done'
  end

  private

  def generate_battery_level(device)
    level = device.battery || 0
    level = level - rand(2)
    level > 0 ? level : 100
  end

  def generate_footfall_count(device)
    hour = Time.now.hour
    range = FOOTFALL_RANGES_BY_HOUR[hour]
    range.to_a.sample
  end

  def write_footfall_data_to_aws(data)
    @db ||= Aws::DynamoDB::Client.new
    @table ||= Rails.configuration.x.aws.footfall_table_name

    params = { table_name: @table, item: data }

    begin
      @db.put_item(params)
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts 'Unable to add footfall data: '
      puts error.message
    end
  end

  FOOTFALL_RANGES_BY_HOUR = [
    (0..5),    # 0
    (0..5),    # 1
    (0..5),    # 2
    (0..5),    # 3
    (0..5),    # 4
    (5..10),   # 5
    (5..15),   # 6
    (5..20),   # 7
    (5..25),   # 8
    (10..30),  # 9
    (10..40),  # 10
    (15..50),  # 11
    (20..60),  # 12
    (30..70),  # 13
    (30..70),  # 14
    (40..80),  # 15
    (40..80),  # 16
    (40..90),  # 17
    (30..70),  # 18
    (20..60),  # 19
    (5..50),   # 20
    (5..20),   # 21
    (0..10),   # 22
    (0..6)     # 23
  ]
end