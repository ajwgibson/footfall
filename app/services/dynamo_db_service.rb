require 'aws-sdk-dynamodb'

class DynamoDbService

  def initialize
    @db = Aws::DynamoDB::Client.new
    @footfall_table_name = Rails.configuration.x.aws.footfall_table_name
  end

  def get_footfall_data(before=Time.now)
    data = []

    params = {
      table_name: @footfall_table_name,
      filter_expression: "#time < :before",
      expression_attribute_names: {
        "#time" => "time"
      },
      expression_attribute_values: {
        ":before" => before.strftime('%FT%T')
      }
    }

    begin
      @db.scan(params).items.each do |item|
        data << {
          dev_id: item['dev_id'],
          time: item['time'],
          footfall: item['footfall'].to_i,
          battery: item['battery']&.to_i
        }
      end
    rescue Aws::DynamoDB::Errors::ServiceError => error
      log_error(error)
    end

    data
  end

  def delete_footfall_data(record)
    params = {
      table_name: @footfall_table_name,
      key: { dev_id: record[:dev_id], time: record[:time] }
    }

    begin
      @db.delete_item(params)
    rescue Aws::DynamoDB::Errors::ServiceError => error
      log_error(error)
    end
  end

  private

  def log_error(error)
    Rails.logger.error error.message
    error.backtrace.each { |line| Rails.logger.error line }
  end
end